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
		op : memu_op_type;
		A, W : data_type;
		D: mem_in_type;
	end record;

	type output_t is
	record
		busy, xl, xs : std_logic;
		R : data_type;
		M : mem_out_type;
	end record;

	signal inp  : input_t;
	signal outp : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.op.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.memtype := str_to_mem_op(l.all);
		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.W := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.D.rddata := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.D.busy := str_to_sl(l(1));
		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.busy := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.xl := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.xs := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.R := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.M.address := bin_to_slv(l.all, ADDR_WIDTH);
		l := get_next_valid_line(f);
		result.M.rd := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.M.wr := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.M.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);
		l := get_next_valid_line(f);
		result.M.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		report " << input:"
			& " op.memread=" & to_string(inp.op.memread)
			& " op.memwrite=" & to_string(inp.op.memwrite)
			& " op.memtype=" & to_string(inp.op.memtype)
			& " A=" & to_string(inp.A)
			& " W=" & to_string(inp.W)
			& " D.rddata=" & to_string(inp.D.rddata)
			& " D.busy=" & to_string(inp.D.busy)
			& lf severity note;
		report " >> output  :"
			& " B=" & to_string(outp.busy)
			& " xl=" & to_string(outp.xl)
			& " xs=" & to_string(outp.xs)
			& " R=" & to_string(outp.R)
			& " M.address=" & to_string(outp.M.address)
			& " M.rd=" & to_string(outp.M.rd)
			& " M.wr=" & to_string(outp.M.wr)
			& " M.byteena=" & to_string(outp.M.byteena)
			& " M.wrdata=" & to_string(outp.M.wrdata)
			& lf severity note;
		if passed then
			report " >> PASSED!" severity note;
		else
			report ">> EXPECTED:"
			& " B=" & to_string(output_ref.busy)
			& " XL=" & to_string(output_ref.xl)
			& " XS=" & to_string(output_ref.xs)
			& " R=" & to_string(output_ref.R)
			& " M.address=" & to_string(output_ref.M.address)
			& " M.rd=" & to_string(output_ref.M.rd)
			& " M.wr=" & to_string(output_ref.M.wr)
			& " M.byteena=" & to_string(output_ref.M.byteena)
			& " M.wrdata=" & to_string(output_ref.M.wrdata)
			& lf severity error;
		end if;
	end procedure;

begin

	memu_inst : entity work.memu
	port map (
		op => inp.op,
		A  => inp.A,
		W  => inp.W,
		R  => outp.R,

		B  => outp.busy,
		XL => outp.xl,
		XS => outp.xs,

		D  => inp.D,
		M  => outp.M
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
