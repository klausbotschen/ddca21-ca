library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;

entity fetch is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- to control
		mem_busy   : out std_logic;

		pcsrc      : in  std_logic;
		pc_in      : in  pc_type;
		pc_out     : out pc_type := (others => '0');
		instr      : out instr_type;

		-- memory controller interface
		mem_out   : out mem_out_type;
		mem_in    : in  mem_in_type
	);
end entity;

architecture rtl of fetch is
	signal pc, pc_next : pc_type;
	signal init : std_logic := '1';
begin
	sync: process(clk, res_n) is
	begin
		if res_n = '0' then
			pc <= x"fffc";
			init <= '1';
		elsif rising_edge(clk) then
			init <= '0';
			if stall = '0' then
				pc <= pc_next;
			end if;
		end if;
	end process;

	with init select pc_out <= pc when '0', (others => '0') when others;
	mem_out.address <= pc_next(pc_next'high downto 2);
	mem_out.rd <= '1';
	mem_out.wr <= '0';
	mem_out.byteena <= "1111";
	mem_out.wrdata <= ZERO_DATA;
	mem_busy <= mem_in.busy;

	async: process(all) is
	begin
		if stall ='0' then
			if pcsrc = '1' then
				pc_next <= pc_in;
			else
				pc_next <= std_logic_vector(unsigned(pc) + 4);
			end if;
		else
			pc_next <= pc;
		end if;
		if flush = '0' and init = '0' then
			instr(31 downto 24) <= mem_in.rddata(7 downto 0);
			instr(23 downto 16) <= mem_in.rddata(15 downto 8);
			instr(15 downto 8) <= mem_in.rddata(23 downto 16);
			instr(7 downto 0) <= mem_in.rddata(31 downto 24);
		else
			instr <= NOP_INST;
		end if;
	end process;
end architecture;
