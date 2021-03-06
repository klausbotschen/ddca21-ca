library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity cache is
	generic (
		SETS_LD   : natural          := SETS_LD;
		WAYS_LD   : natural          := WAYS_LD;
		ADDR_MASK : mem_address_type := (others => '1')
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		mem_out_cpu : in  mem_out_type;
		mem_in_cpu  : out mem_in_type;
		mem_out_mem : out mem_out_type;
		mem_in_mem  : in  mem_in_type
	);
end entity;

architecture bypass of cache is --bypass cache for exIII and testing
	alias cpu_to_cache : mem_out_type is mem_out_cpu; 
	alias cache_to_cpu : mem_in_type is mem_in_cpu;   
	alias cache_to_mem : mem_out_type is mem_out_mem; 
	alias mem_to_cache : mem_in_type is mem_in_mem;   
begin
	cache_to_mem <= cpu_to_cache; 
	cache_to_cpu <= mem_to_cache; 
end architecture;

architecture impl of cache is
	type CACHE_STATE is (C_IDLE,
		C_RD_CACHE,      -- get cache entry
		C_RD_MEM_START,  -- miss, first read cycle to mem
		C_RD_MEM_WAIT,   -- wait mem completion
		C_WB_START,      -- dirty, first write cycle
		C_WB             -- finish write
	);
	signal index : c_index_type := (others => '0');
	signal rd, wr, wrv, valid_in, valid_out : std_logic := '0';
	signal dirty_in, dirty_out, hit: std_logic := '0';
	signal bypass_n : std_logic;
	signal way_out : c_way_type;
	signal tag_in, tag_out, tao_next : c_tag_type;
	signal data_in, data_out : mem_data_type;
	signal byteena : mem_byteena_type;
	
	-- registers
	signal state, state_next : CACHE_STATE;
begin

	cmgmnt : entity work.mgmt_st(impl)
	  generic map (
			SETS_LD => SETS_LD,
			WAYS_LD => WAYS_LD
		)
		port map (
			clk     => clk,
			res_n   => res_n,
			index   => index,
			wr      => wr, -- write dirty+data
			wrv     => wrv, -- write valid bit
			rd	    => rd,
			valid_in     => valid_in,
			dirty_in     => dirty_in,
			tag_in       => tag_in,
			way_out      => open,
			valid_out    => valid_out,
			dirty_out    => dirty_out,
			tag_out      => tao_next,
			hit_out      => hit
	);
	
	cdata : entity work.data_st(impl)
	  generic map (
			SETS_LD => SETS_LD,
			WAYS_LD => WAYS_LD
		)
		port map (
			clk     => clk,
			we      => wr,
			rd	    => rd,
			way     => (others => '0'),
			index   => index,
			byteena => byteena,
			data_in  => data_in,
			data_out => data_out
	);
	
	bypass_n <= '1' when (mem_out_cpu.address and not ADDR_MASK) = MEM_OUT_NOP.address else '0';
	-- address is in words
	tag_in <= mem_out_cpu.address(ADDR_WIDTH-1 downto SETS_LD);
	index <= mem_out_cpu.address(SETS_LD-1 downto 0);
	
	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			state <= C_IDLE;
			tag_out <= (others => '0');
		elsif rising_edge(clk) then
			state <= state_next;
			if state = C_IDLE then
				tag_out <= tao_next;
			end if;
		end if;
	end process;

	fsm : process(all)
	begin
		state_next <= state;
		mem_out_mem <= MEM_OUT_NOP;
		mem_in_cpu <= MEM_IN_NOP;
		byteena <= (others => '0');
		rd <= '0';
		wr <= '0';
		wrv <= '0';
		valid_in <= '0';
		dirty_in <= '0';
		data_in <= (others => '0');
		case state is
			when C_IDLE =>
				if bypass_n = '0' then       -- bypass
					mem_out_mem <= mem_out_cpu; 
					mem_in_cpu <= mem_in_mem; 
				else
					rd <= mem_out_cpu.rd or mem_out_cpu.wr; -- check cache
					if hit = '0' then          -- cache miss
						if mem_out_cpu.rd = '1' then
							if valid_out = '1' and dirty_out = '1' then
								-- prepare write back, wait for data from cache
								state_next <= C_WB_START;
							else
								state_next <= C_RD_MEM_START;
							end if;
						elsif mem_out_cpu.wr = '1' then -- direct write
							mem_out_mem <= mem_out_cpu;
						end if;
					else                       -- cache hit
						if mem_out_cpu.rd = '1' then
							state_next <= C_RD_CACHE;
						elsif mem_out_cpu.wr = '1' then -- instant store in cache
							dirty_in <= '1';
							byteena <= mem_out_cpu.byteena;
							data_in <= mem_out_cpu.wrdata;
							wr <= '1';
						end if;
					end if;
				end if;
			when C_RD_CACHE =>      -- get cache entry
				mem_in_cpu.rddata <= data_out;
				state_next <= C_IDLE;
			when C_WB_START =>      -- write back, single clock write cycle
				mem_out_mem.address(ADDR_WIDTH-1 downto SETS_LD) <= tag_out;
				mem_out_mem.address(SETS_LD-1 downto 0) <= index;
				mem_out_mem.rd <= '0';
				mem_out_mem.wr <= '1';
				mem_out_mem.byteena <= (others => '1');
				mem_out_mem.wrdata <= data_out;
				mem_in_cpu.busy <= '1';
				state_next <= C_WB;
			when C_WB =>            -- write back done, start read cycle
				mem_out_mem <= mem_out_cpu;
				mem_out_mem.rd <= '1';
				mem_in_cpu.busy <= '1';
				state_next <= C_RD_MEM_WAIT;
			when C_RD_MEM_START =>  -- first read cycle to mem
				mem_out_mem <= mem_out_cpu;
				mem_out_mem.rd <= '1';
				mem_in_cpu.busy <= '1';
				state_next <= C_RD_MEM_WAIT;
			when C_RD_MEM_WAIT =>   -- wait mem completion
				mem_out_mem <= mem_out_cpu;
				mem_in_cpu.busy <= '1';
				mem_in_cpu.rddata <= mem_in_mem.rddata;
				if mem_in_mem.busy = '0' then
					state_next <= C_IDLE;
					-- forward to CPU
					mem_in_cpu.busy <= '0';
					-- write to cache
					valid_in <= '1';
					dirty_in <= '0';
					byteena <= (others => '1');
					data_in <= mem_in_mem.rddata;
					wr <= '1';
					wrv <= '1';
				end if;
		end case;
	end process;

end architecture;
