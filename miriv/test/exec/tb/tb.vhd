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
		stall     : std_logic;
		flush     : std_logic;
		op        : exec_op_type;
		pc_in     : pc_type;
		mem_op_in : mem_op_type;
		wb_op_in  : wb_op_type;
		reg_write_mem  : reg_write_type;
		reg_write_wr   : reg_write_type;
	end record;

	type output_t is
	record
		pc_old_out : pc_type;
		pc_new_out : pc_type;
		aluresult  : data;
		wrdata     : data;
		zero       : std_logic;
		exec_op    : exec_op_type;
		mem_op_out : mem_op_type;
		wb_op_out  : wb_op_type;
	end record;
	
	constant REG_WRITE_DUMMY : reg_write_type := (
		'0',
		(others => '0'),
		(others => '0')
	);
	
	signal inp  : input_t := (
		'0',
		'0',
		EXEC_NOP,
		(others => '0'),
		MEM_NOP,
		WB_NOP,
		REG_WRITE_DUMMY,
		REG_WRITE_DUMMY
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
		result.op.aluop := str_to_alu_op(l.all);
		l := get_next_valid_line(f);
		result.op.alusrc1 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.alusrc2 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.alusrc3 := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.rs1 := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.op.rs2 := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.op.readdata1 := hex_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.op.readdata2 := hex_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.op.imm := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.pc_in := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.mem_op_in.branch := str_to_branch_op(l.all);
		l := get_next_valid_line(f);
		result.mem_op_in.mem.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op_in.mem.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op_in.mem.memtype := str_to_mem_op(l.all);

		l := get_next_valid_line(f);
		result.wb_op_in.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.wb_op_in.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.wb_op_in.src := str_to_wbs_op(l.all);

		l := get_next_valid_line(f);
		result.reg_write_mem.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.reg_write_mem.reg := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.reg_write_mem.data := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.reg_write_wr.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.reg_write_wr.reg := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.reg_write_wr.data := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.pc_old_out := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.pc_new_out := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.aluresult := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.wrdata := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.zero := str_to_sl(l(1));

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
		result.exec_op.readdata1 := hex_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.exec_op.readdata2 := hex_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.exec_op.imm := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.mem_op_out.branch := str_to_branch_op(l.all);
		l := get_next_valid_line(f);
		result.mem_op_out.mem.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op_out.mem.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op_out.mem.memtype := str_to_mem_op(l.all);

		l := get_next_valid_line(f);
		result.wb_op_out.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.wb_op_out.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.wb_op_out.src := str_to_wbs_op(l.all);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);
		
		report " << input:"
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " op {aluop=" & to_string(inp.op.aluop)
			& " alusrc1=" & to_string(inp.op.alusrc1)
			& " alusrc2=" & to_string(inp.op.alusrc2)
			& " alusrc3=" & to_string(inp.op.alusrc3)
			& " rs1=" & to_string(inp.op.rs1)
			& " rs2=" & to_string(inp.op.rs2)
			& " readdata1=" & to_string(inp.op.readdata1)
			& " readdata2=" & to_string(inp.op.readdata2)
			& " imm=" & to_string(inp.op.imm)
			& "} pc_in=" & to_string(inp.pc_in)
			& " mem_op_in {branch=" & to_string(inp.mem_op_in.branch)
			& " mem.memread=" & to_string(inp.mem_op_in.mem.memread)
			& " mem.memwrite=" & to_string(inp.mem_op_in.mem.memwrite)
			& " mem.memtype=" & to_string(inp.mem_op_in.mem.memtype)
			& "} wb_op_in {rd=" & to_string(inp.wb_op_in.rd)
			& " write=" & to_string(inp.wb_op_in.write)
			& " src=" & to_string(inp.wb_op_in.src)
			& "} reg_write_mem {write=" & to_string(inp.reg_write_mem.write)
			& " reg=" & to_string(inp.reg_write_mem.reg)
			& " data=" & to_string(inp.reg_write_mem.data)
			& " reg_write_wr {write=" & to_string(inp.reg_write_wr.write)
			& " reg=" & to_string(inp.reg_write_wr.reg)
			& " data=" & to_string(inp.reg_write_wr.data)
			& "}" & lf severity note;
		report " >> output  :"
			& " pc_old_out=" & to_string(outp.pc_old_out)
			& " pc_new_out=" & to_string(outp.pc_new_out)
			& " aluresult=" & to_string(outp.aluresult)
			& " wrdata=" & to_string(outp.wrdata)
			& " zero=" & to_string(outp.zero)
			& " exec_op {aluop=" & to_string(outp.exec_op.aluop)
			& " alusrc1=" & to_string(outp.exec_op.alusrc1)
			& " alusrc2=" & to_string(outp.exec_op.alusrc2)
			& " alusrc3=" & to_string(outp.exec_op.alusrc3)
			& " rs1=" & to_string(outp.exec_op.rs1)
			& " rs2=" & to_string(outp.exec_op.rs2)
			& " readdata1=" & to_string(outp.exec_op.readdata1)
			& " readdata2=" & to_string(outp.exec_op.readdata2)
			& " imm=" & to_string(outp.exec_op.imm)
			& "} mem_op_out {branch=" & to_string(outp.mem_op_out.branch)
			& " mem.memread=" & to_string(outp.mem_op_out.mem.memread)
			& " mem.memwrite=" & to_string(outp.mem_op_out.mem.memwrite)
			& " mem.memtype=" & to_string(outp.mem_op_out.mem.memtype)
			& "} wb_op_out {rd=" & to_string(outp.wb_op_out.rd)
			& " write=" & to_string(outp.wb_op_out.write)
			& " src=" & to_string(outp.wb_op_out.src)
			& "}"
			& lf severity note;

		if passed then
			report " >> PASSED!" severity note;
		else
			report ">> EXPECTED:"
			& " pc_old_out=" & to_string(output_ref.pc_old_out)
			& " pc_new_out=" & to_string(output_ref.pc_new_out)
			& " aluresult=" & to_string(output_ref.aluresult)
			& " wrdata=" & to_string(output_ref.wrdata)
			& " zero=" & to_string(output_ref.zero)
			& " exec_op {aluop=" & to_string(output_ref.exec_op.aluop)
			& " alusrc1=" & to_string(output_ref.exec_op.alusrc1)
			& " alusrc2=" & to_string(output_ref.exec_op.alusrc2)
			& " alusrc3=" & to_string(output_ref.exec_op.alusrc3)
			& " rs1=" & to_string(output_ref.exec_op.rs1)
			& " rs2=" & to_string(output_ref.exec_op.rs2)
			& " readdata1=" & to_string(output_ref.exec_op.readdata1)
			& " readdata2=" & to_string(output_ref.exec_op.readdata2)
			& " imm=" & to_string(output_ref.exec_op.imm)
			& "} mem_op_out {branch=" & to_string(output_ref.mem_op_out.branch)
			& " mem.memread=" & to_string(output_ref.mem_op_out.mem.memread)
			& " mem.memwrite=" & to_string(output_ref.mem_op_out.mem.memwrite)
			& " mem.memtype=" & to_string(output_ref.mem_op_out.mem.memtype)
			& "} wb_op_out {rd=" & to_string(output_ref.wb_op_out.rd)
			& " write=" & to_string(output_ref.wb_op_out.write)
			& " src=" & to_string(output_ref.wb_op_out.src)
			& "}"
			& lf severity error;
		end if;
	end procedure;

begin

	exec_inst : entity work.exec
	port map (
		clk => clk,
		res_n => res_n,
		stall => inp.stall,
		flush => inp.flush,
		op => inp.op,
		pc_in => inp.pc_in,
		pc_old_out => outp.pc_old_out,
		pc_new_out => outp.pc_new_out,
		aluresult => outp.aluresult,
		wrdata => outp.wrdata,
		zero => outp.zero,
		memop_in => inp.mem_op_in,
		memop_out => outp.mem_op_out,
		wbop_in => inp.wb_op_in,
		wbop_out => outp.wb_op_out,
		exec_op => outp.exec_op,
		reg_write_mem => inp.reg_write_mem,
		reg_write_wr => inp.reg_write_wr
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
