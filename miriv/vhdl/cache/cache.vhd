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
	signal index : c_index_type;
	signal rd, wr, valid_in, valid_out : std_logic;
	signal dirty_in, dirty_out, hit_out: std_logic;
	signal bypass_n : std_logic;
	signal way_out : c_way_type;
	signal tag_in, tag_out : c_tag_type;
	
	type statevar_t is record
		state : CACHE_STATE;
	end record;
	constant STATEVAR_NUL : statevar_t := (
		state   => C_IDLE
	);
	signal cs, csn: statevar_t;
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
			wr      => wr,
			rd	    => rd,
			valid_in     => valid_in,
			dirty_in     => dirty_in,
			tag_in       => tag_in,
			way_out      => open,
			valid_out    => valid_out,
			dirty_out    => open,
			tag_out      => open,
			hit_out      => open
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
			byteena => mem_out_cpu.byteena,
			data_in  => mem_out_cpu.wrdata,
			data_out => mem_in_cpu.rddata
	);
	
	bypass_n <= '1' when unsigned(mem_out_cpu.address and not ADDR_MASK) = 0 else '0';
	-- address is in words
	tag_in <= mem_out_cpu.address(ADDR_WIDTH-1 downto SETS_LD);
	index <= mem_out_cpu.address(SETS_LD-1 downto 0);
	rd <= bypass_n and mem_out_cpu.rd;
	wr <= bypass_n and mem_out_cpu.wr;
	
	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			cs <= STATEVAR_NUL;
		elsif rising_edge(clk) then
			cs <= csn;
		end if;
	end process;

	fsm : process(all)
	begin
		csn <= cs;
		case cs.state is
			when C_IDLE =>
			when C_RD_CACHE =>      -- get cache entry
			when C_RD_MEM_START =>  -- miss, first read cycle to mem
			when C_RD_MEM_WAIT =>   -- wait mem completion
			when C_WB_START =>      -- dirty, first write cycle
			when C_WB =>            -- finish write
		end case;
	end process;

end architecture;
