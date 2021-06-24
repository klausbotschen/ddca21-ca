library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

use work.mem_pkg.all;
use work.op_pkg.all;
use work.core_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is
	constant CLK_PERIOD : time := 10 ns;

	signal clk : std_logic;
	signal res_n : std_logic := '0';
	signal stop : boolean := false;
	
	signal mco, mmo: mem_out_type;
	signal mci, mmi: mem_in_type;

begin

	uut : entity work.cache
	generic map (
		SETS_LD   => 3,
		WAYS_LD   => 1,
		ADDR_MASK => 14x"0FFF"
	)
	port map (
		clk   => clk,
		res_n => res_n,

		mem_out_cpu => mco,
		mem_in_cpu  => mci,
		mem_out_mem => mmo,
		mem_in_mem  => mmi
	);

	stimulus : process
		variable fstatus: file_open_status;
	begin
		res_n <= '0';
		wait until rising_edge(clk);
		res_n <= '1';

		mco.address <= (others => '0');
		mco.rd <= '1';
		mco.wr <= '0';
		mco.byteena <= "1111";
		mco.wrdata <= (others => '0');

		mmi.busy <= '0';
		mmi.rddata <= (others => '0');

		wait until rising_edge(clk);
		
		wait;
	end process;


	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;