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
		stall, flush: std_logic;
		pc_in     : pc_type;
		instr     : instr_type;
		reg_write : reg_write_type;
	end record;

	type output_t is
	record
		pc_out     : pc_type;
		exec_op    : exec_op_type;
		mem_op     : mem_op_type;
		wb_op      : wb_op_type;
		exc_dec    : std_logic;
	end record;

	signal inp  : input_t;
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
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);
		l := get_next_valid_line(f);
		result.instr := bin_to_slv(l.all, INSTR_WIDTH);
		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.reg_write.data := bin_to_slv(l.all, DATA_WIDTH);
		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.pc_out := bin_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.exec_op.aluop := str_to_alu_op(l.all);
		l := get_next_valid_line(f);
		result.exec_op.alusrc1 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.exec_op.alusrc2 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.exec_op.alusrc3 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.exec_op.rs1 := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.exec_op.rs2 := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.exec_op.readdata1 := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.exec_op.readdata2 := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.exec_op.imm := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.mem_op.branch := str_to_branch_op(l.all);
		l := get_next_valid_line(f);
		result.mem_op.mem.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op.mem.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op.mem.memtype := str_to_mem_op(l.all);

		l := get_next_valid_line(f);
		result.wb_op.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.wb_op.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.wb_op.src := str_to_wbs_op(l.all);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		report " << input:"
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " pc_in=" & to_string(inp.pc_in)
			& " instr=" & to_string(inp.instr)
			& " reg_write.write=" & to_string(inp.reg_write.write)
			& " reg_write.reg=" & to_string(inp.reg_write.reg)
			& " reg_write.data=" & to_string(inp.reg_write.data)
			& lf severity note;
		report " >> output  :"
			& " pc_out=" & to_string(outp.pc_out)
			& " exec_op.aluop=" & to_string(outp.exec_op.aluop)
			& " exec_op.alusrc1=" & to_string(outp.exec_op.alusrc1)
			& " exec_op.alusrc2=" & to_string(outp.exec_op.alusrc2)
			& " exec_op.alusrc3=" & to_string(outp.exec_op.alusrc3)
			& " exec_op.rs1=" & to_string(outp.exec_op.rs1)
			& " exec_op.rs2=" & to_string(outp.exec_op.rs2)
			& " exec_op.readdata1=" & to_string(outp.exec_op.readdata1)
			& " exec_op.readdata2=" & to_string(outp.exec_op.readdata1)
			& " exec_op.imm=" & to_string(outp.exec_op.imm)

			& " mem_op.branch=" & to_string(outp.mem_op.branch)
			& " mem_op.mem.memread=" & to_string(outp.mem_op.mem.memread)
			& " mem_op.mem.memwrite=" & to_string(outp.mem_op.mem.memwrite)
			& " mem_op.mem.memtype=" & to_string(outp.mem_op.mem.memtype)
			& " wb_op.rd=" & to_string(outp.wb_op.rd)
			& " wb_op.write=" & to_string(outp.wb_op.write)
			& " wb_op.src=" & to_string(outp.wb_op.src)
			& lf severity note;
		if passed then
			report " >> PASSED!" severity note;
		else
			report ">> EXPECTED:"
			& " pc_out=" & to_string(output_ref.pc_out)
			& " exec_op.aluop=" & to_string(output_ref.exec_op.aluop)
			& " exec_op.alusrc1=" & to_string(output_ref.exec_op.alusrc1)
			& " exec_op.alusrc2=" & to_string(output_ref.exec_op.alusrc2)
			& " exec_op.alusrc3=" & to_string(output_ref.exec_op.alusrc3)
			& " exec_op.rs1=" & to_string(output_ref.exec_op.rs1)
			& " exec_op.rs2=" & to_string(output_ref.exec_op.rs2)
			& " exec_op.readdata1=" & to_string(output_ref.exec_op.readdata1)
			& " exec_op.readdata2=" & to_string(output_ref.exec_op.readdata1)
			& " exec_op.imm=" & to_string(output_ref.exec_op.imm)

			& " mem_op.branch=" & to_string(output_ref.mem_op.branch)
			& " mem_op.mem.memread=" & to_string(output_ref.mem_op.mem.memread)
			& " mem_op.mem.memwrite=" & to_string(output_ref.mem_op.mem.memwrite)
			& " mem_op.mem.memtype=" & to_string(output_ref.mem_op.mem.memtype)
			& " wb_op.rd=" & to_string(output_ref.wb_op.rd)
			& " wb_op.write=" & to_string(output_ref.wb_op.write)
			& " wb_op.src=" & to_string(output_ref.wb_op.src)
			& lf severity error;
		end if;
	end procedure;

begin

	decode_inst : entity work.decode
	port map (
		clk        => clk,
		res_n      => res_n,
		stall      => inp.stall,
		flush      => inp.flush,

		-- from fetch
		pc_in      => inp.pc_in,
		instr      => inp.instr,

		-- from writeback
		reg_write  => inp.reg_write,

		-- towards next stages
		pc_out     => outp.pc_out,
		exec_op    => outp.exec_op,
		mem_op     => outp.mem_op,
		wb_op      => outp.wb_op,

		-- exceptions
		exc_dec    => outp.exc_dec
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
