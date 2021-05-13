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
begin
	sync: process(clk, res_n) is
	begin
		if res_n = '0' then
			pc <= x"fffc";
		elsif rising_edge(clk) then
			if stall = '0' then
				pc <= pc_next;
			end if;
		end if;
	end process;

	pc_out <= pc;
	mem_out.address <= pc_next(pc_next'high downto 2);
	mem_out.rd <= '1';
	mem_out.wr <= '0';
	mem_out.byteena <= "1111";
	mem_out.wrdata <= ZERO_DATA;
	mem_busy <= mem_in.busy;

	async: process(all) is
	begin
		if pcsrc = '1' and stall = '0' then
			pc_next <= pc_in;
		else
			pc_next <= std_logic_vector(unsigned(pc) + 4);
		end if;
		if flush = '0' then
			instr(31 downto 24) <= mem_in.rddata(7 downto 0);
			instr(23 downto 16) <= mem_in.rddata(15 downto 8);
			instr(15 downto 8) <= mem_in.rddata(23 downto 16);
			instr(7 downto 0) <= mem_in.rddata(31 downto 24);
		else
			instr <= NOP_INST;
		end if;
	end process;
end architecture;
