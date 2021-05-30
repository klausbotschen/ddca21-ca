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
		mem_op    : mem_op_type;
		wbop_in   : wb_op_type;
		pc_new_in : pc_type;
		pc_old_in : pc_type;
		aluresult_in   : data;
		wrdata    : data;
		zero      : std_logic;
		mem_in    : mem_in_type;
	end record;

	type output_t is
	record
		mem_busy   : std_logic;
		reg_write  : reg_write_type;
		pc_new_out : pc_type;
		pcsrc      : std_logic;
		wbop_out   : wb_op_type;
		pc_old_out : pc_type;
		aluresult_out : data;
		memresult  : data;
		mem_out    : mem_out_type;
		exc_load   : std_logic;
		exc_store  : std_logic;
	end record;

	signal inp  : input_t := (
		'0',
		'0',
		MEM_NOP,
		WB_NOP,
		(others => '0'),
		(others => '0'),
		(others => '0'),
		(others => '0'),
		'0',
		MEM_IN_NOP
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
		result.mem_op.branch := str_to_branch_op(l.all);
		l := get_next_valid_line(f);
		result.mem_op.mem.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op.mem.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_op.mem.memtype := str_to_mem_op(l.all);

		l := get_next_valid_line(f);
		result.wbop_in.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.wbop_in.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.wbop_in.src := str_to_wbs_op(l.all);

		l := get_next_valid_line(f);
		result.pc_new_in := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.pc_old_in := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.aluresult_in := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.wrdata := bin_to_slv(l.all, DATA_WIDTH); -- use bin here as well as at output

		l := get_next_valid_line(f);
		result.zero := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_in.busy := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_in.rddata := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.mem_busy := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.reg_write.data := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.pc_new_out := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.pcsrc := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.wbop_out.rd := bin_to_slv(l.all, REG_BITS);
		l := get_next_valid_line(f);
		result.wbop_out.write := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.wbop_out.src := str_to_wbs_op(l.all);

		l := get_next_valid_line(f);
		result.pc_old_out := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.aluresult_out := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.memresult := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.mem_out.address := bin_to_slv(l.all, ADDR_WIDTH);
		l := get_next_valid_line(f);
		result.mem_out.rd := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_out.wr := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.mem_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);
		l := get_next_valid_line(f);
		result.mem_out.wrdata := bin_to_slv(l.all, DATA_WIDTH); -- use bin here to parse '-'

		l := get_next_valid_line(f);
		result.exc_load := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.exc_store := str_to_sl(l(1));

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		report " << input :"
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " mem_op {branch=" & to_string(inp.mem_op.branch)
			& " mem.memread=" & to_string(inp.mem_op.mem.memread)
			& " mem.memwrite=" & to_string(inp.mem_op.mem.memwrite)
			& " mem.memtype=" & to_string(inp.mem_op.mem.memtype)
			& "} wbop_in {rd=" & to_string(inp.wbop_in.rd)
			& " write=" & to_string(inp.wbop_in.write)
			& " src=" & to_string(inp.wbop_in.src)
			& "} pc_new_in=" & to_string(inp.pc_new_in)
			& " pc_old_in=" & to_string(inp.pc_old_in)
			& " aluresult_in=" & to_string(inp.aluresult_in)
			& " wrdata=" & to_string(inp.wrdata)
			& " zero=" & to_string(inp.zero)
			& " mem_in {busy=" & to_string(inp.mem_in.busy)
			& " rddata=" & to_string(inp.mem_in.rddata)
			& " }"
			& lf severity note;
		report " >> output  :"
			& " mem_busy=" & to_string(outp.mem_busy)
			& " reg_write {write=" & to_string(outp.reg_write.write)
			& " reg=" & to_string(outp.reg_write.reg)
			& " data=" & to_string(outp.reg_write.data)
			& "} pc_new_out=" & to_string(outp.pc_new_out)
			& " pcsrc=" & to_string(outp.pcsrc)
			& " wbop_out {rd=" & to_string(outp.wbop_out.rd)
			& " write=" & to_string(outp.wbop_out.write)
			& " src=" & to_string(outp.wbop_out.src)
			& "} pc_old_out=" & to_string(outp.pc_old_out)
			& " aluresult_out=" & to_string(outp.aluresult_out)
			& " memresult=" & to_string(outp.memresult)
			& " mem_out {address=" & to_string(outp.mem_out.address)
			& " rd=" & to_string(outp.mem_out.rd)
			& " wr=" & to_string(outp.mem_out.wr)
			& " byteena=" & to_string(outp.mem_out.byteena)
			& " wrdata=" & to_string(outp.mem_out.wrdata)
			& "} exc_load=" & to_string(outp.exc_load)
			& " exc_store=" & to_string(outp.exc_store)
			& lf severity note;

		if passed then
			report " >> PASSED!" severity note;
		else
			report ">> EXPECTED:"
			& " mem_busy=" & to_string(output_ref.mem_busy)
			& " reg_write {write=" & to_string(output_ref.reg_write.write)
			& " reg=" & to_string(output_ref.reg_write.reg)
			& " data=" & to_string(output_ref.reg_write.data)
			& "} pc_new_out=" & to_string(output_ref.pc_new_out)
			& " pcsrc=" & to_string(output_ref.pcsrc)
			& " wbop_out {rd=" & to_string(output_ref.wbop_out.rd)
			& " write=" & to_string(output_ref.wbop_out.write)
			& " src=" & to_string(output_ref.wbop_out.src)
			& "} pc_old_out=" & to_string(output_ref.pc_old_out)
			& " aluresult_out=" & to_string(output_ref.aluresult_out)
			& " memresult=" & to_string(output_ref.memresult)
			& " mem_out {address=" & to_string(output_ref.mem_out.address)
			& " rd=" & to_string(output_ref.mem_out.rd)
			& " wr=" & to_string(output_ref.mem_out.wr)
			& " byteena=" & to_string(output_ref.mem_out.byteena)
			& " wrdata=" & to_string(output_ref.mem_out.wrdata)
			& "} exc_load=" & to_string(output_ref.exc_load)
			& " exc_store=" & to_string(output_ref.exc_store)
			& lf severity error;
		end if;
	end procedure;

begin

	mem_inst : entity work.mem
	port map (
		clk => clk,
		res_n => res_n,
		stall => inp.stall,
		flush => inp.flush,
		mem_busy => outp.mem_busy,
		mem_op => inp.mem_op,
		wbop_in => inp.wbop_in,
		pc_new_in => inp.pc_new_in,
		pc_old_in => inp.pc_old_in,
		aluresult_in => inp.aluresult_in,
		wrdata => inp.wrdata,
		zero => inp.zero,
		reg_write => outp.reg_write,
		pc_new_out => outp.pc_new_out,
		pcsrc => outp.pcsrc,
		wbop_out => outp.wbop_out,
		pc_old_out => outp.pc_old_out,
		aluresult_out => outp.aluresult_out,
		memresult => outp.memresult,
		mem_out => outp.mem_out,
		mem_in => inp.mem_in,
		exc_load => outp.exc_load,
		exc_store => outp.exc_store
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
