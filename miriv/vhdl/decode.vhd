library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity decode is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from fetch
		pc_in      : in  pc_type;
		instr      : in  instr_type;

		-- from writeback
		reg_write  : in reg_write_type;

		-- towards next stages
		pc_out     : out pc_type;
		exec_op    : out exec_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;

		-- exceptions
		exc_dec    : out std_logic
	);
end entity;

architecture rtl of decode is
	signal pc_next : pc_type;
	signal rdaddr1, rdaddr2 : reg_adr_type;
	signal wraddr : reg_adr_type;
	signal wrdata : data_type;
	signal regwrite : std_logic;

begin

	-- --------------------------------------------
	regfile_inst : entity work.regfile
	port map (
		clk        => clk,
		res_n      => res_n,
		stall      => stall,
		rdaddr1    => rdaddr1,
		rdaddr2    => rdaddr2,
		rddata1    => exec_op.readdata1,
		rddata2    => exec_op.readdata2,
		wraddr     => wraddr,
		wrdata     => wrdata,
		regwrite   => regwrite
	);
	-- --------------------------------------------

	pc_next <= pc_in;

sync: process(clk, res_n) is
	begin
		if res_n = '0' then
		elsif rising_edge(clk) then
			if stall = '0' then
				pc_out <= pc_next;
			end if;
		end if;
	end process;

end architecture;
