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
	
	file input_file : text;
	file output_ref_file : text;

	type input_t is
	record
		opA   : data_type;
		opB   : data_type;
		opT    : alu_op_type;
	end record;

	type output_t is
	record
		aluR : data_type;
		zeroflag : std_logic;
	end record;

	signal inp  : input_t := (
		(others => '0'),
		(others => '0'),
		ALU_NOP
	);
	signal outp : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.opA := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.opB := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.opT := str_to_alu_op(l.all);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.aluR := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.zeroflag := str_to_sl(l(1));
		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if passed then
			report " PASSED: "
			& "A="     & to_string(inp.opA)
			& " B="  & to_string(inp.opB)
			& " op="  & to_string(inp.opT)
			& " R="  & to_string(outp.aluR)
			& " Z="  & to_string(outp.zeroflag) & lf
			severity note;
		else
			report "FAILED: "
			& "A="     & to_string(inp.opA)
			& " B="  & to_string(inp.opB)
			& " op="  & to_string(inp.opT) & lf
			& "**     expected: R=" & to_string(output_ref.aluR) & " Z=" & to_string(output_ref.zeroflag) & lf
			& "**     actual:   R=" & to_string(outp.aluR)       & " Z=" & to_string(outp.zeroflag) & lf
			severity error;
		end if;
	end procedure;

begin

	alu_inst : entity work.alu
	port map (
		A    => inp.opA,
		B    => inp.opB,
		op   => inp.opT,
		R    => outp.aluR,
		Z    => outp.zeroflag
	);

	stimulus : process
		variable fstatus: file_open_status;
	begin
		res_n <= '0';
		wait until rising_edge(clk);
		res_n <= '1';
		
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
			timeout(1, CLK_PERIOD);
		end loop;
		
		wait;
	end process;

	output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : output_t;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);

			wait until falling_edge(clk);
			check_output(output_ref);
			wait until rising_edge(clk);
		end loop;
		stop <= true;
		
		wait;
	end process;

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;
