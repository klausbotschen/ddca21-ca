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

	subtype addr is std_logic_vector(REG_BITS-1 downto 0);
	subtype data is std_logic_vector(DATA_WIDTH-1 downto 0);

	type input_t is
	record
		stall      : std_logic;
		flush      : std_logic;
		op         : wb_op_type;
		aluresult  : data;
		memresult  : data;
		pc_old_in  : pc_type;
	end record;

	type output_t is
	record
		reg_write : reg_write_type;
	end record;

	signal inp  : input_t := (
		'0',
		'0',
		WB_NOP,
		(others => '0'),
		(others => '0'),
		(others => '0')
	);
	signal outp : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.stall := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.flush := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.op.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.src := str_to_wbs_op(l.all);

		l := get_next_valid_line(f);
		result.aluresult := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.memresult := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.pc_old_in := hex_to_slv(l.all, PC_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.reg_write.data := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		report " << input:"
			& "stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " op {rd=" & to_string(inp.op.rd)
			& " write=" & to_string(inp.op.write)
			& " src=" & to_string(inp.op.src)
			& "} aluresult=" & to_string(inp.aluresult)
			& " memresult=" & to_string(inp.memresult)
			& " pc_old_in=" & to_string(inp.pc_old_in)
			& lf severity note;
		report " >> output  :"
			& " reg_write {write=" & to_string(outp.reg_write.write)
			& " reg=" & to_string(outp.reg_write.reg)
			& " data=" & to_string(outp.reg_write.data)
			& "}"
			& lf severity note;

		if passed then
			report " >> PASSED!" severity note;
		else
			report ">> EXPECTED:"
			& " reg_write {write=" & to_string(output_ref.reg_write.write)
			& " reg=" & to_string(output_ref.reg_write.reg)
			& " data=" & to_string(output_ref.reg_write.data)
			& "}"
			& lf severity error;
		end if;
	end procedure;

begin

	wb_inst : entity work.wb
	port map (
		clk => clk,
		res_n => res_n,
		stall => inp.stall,
		flush => inp.flush,
		op => inp.op,
		aluresult => inp.aluresult,
		memresult => inp.memresult,
		pc_old_in => inp.pc_old_in,
		reg_write => outp.reg_write
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
