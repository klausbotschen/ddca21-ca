library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;
use work.fetch;
use work.decode;
use work.exec;
use work.mem;
use work.wb;

entity pipeline is
	port (
		clk    : in  std_logic;
		res_n  : in  std_logic;

		-- instruction interface
		mem_i_out    : out mem_out_type;
		mem_i_in     : in  mem_in_type;

		-- data interface
		mem_d_out    : out mem_out_type;
		mem_d_in     : in  mem_in_type
	);
end entity;

architecture impl of pipeline is
	
	signal stall : std_logic;
	signal flush : std_logic;
	
	signal stall_fetch : std_logic;
	signal flush_fetch : std_logic;
	signal mem_busy_from_fetch : std_logic;
	signal pc_from_fetch : pc_type;
	signal instr : instr_type;
	
	signal stall_dec : std_logic;
	signal flush_dec : std_logic;
	signal pc_from_decode : pc_type;
	signal execop_from_decode : exec_op_type;
	signal memop_from_decode : mem_op_type;
	signal wbop_from_decode : wb_op_type;
	signal exc_dec : std_logic;
	
	signal stall_exec : std_logic;
	signal flush_exec : std_logic;
	signal pc_old_from_exec : pc_type;
	signal pc_new_from_exec : pc_type;
	signal aluresult_from_exec : data_type;
	signal wrdata : data_type;
	signal zero : std_logic;
	signal memop_from_exec : mem_op_type;
	signal wbop_from_exec : wb_op_type;
	signal exec_op : exec_op_type;
	
	signal stall_mem : std_logic;
	signal flush_mem : std_logic;
	signal mem_busy_from_mem : std_logic;
	signal reg_write_from_mem : reg_write_type;
	signal pc_new_from_mem : pc_type;
	signal pcsrc : std_logic;
	signal wbop_from_mem : wb_op_type;
	signal pc_old_from_mem : pc_type;
	signal aluresult_from_mem : data_type;
	signal memresult : data_type;
	signal exc_load : std_logic;
	signal exc_store : std_logic;
	
	signal stall_wb : std_logic;
	signal flush_wb : std_logic;
	signal reg_write_from_wb : reg_write_type;
	
	signal reg_write_mem : reg_write_type;
	signal reg_write_wr : reg_write_type;
	
begin
	
	-- exercise III:
	flush <= '0';
	stall <= '1' when mem_busy_from_fetch = '1' or mem_busy_from_mem = '1' else '0';

	fetch_inst : entity work.fetch
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		mem_busy => mem_busy_from_fetch,
		pcsrc => pcsrc,
		pc_in => pc_new_from_mem,
		pc_out => pc_from_fetch,
		instr => instr,
		mem_out => mem_i_out,
		mem_in => mem_i_in
	);

	decode_inst : entity work.decode
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		pc_in => pc_from_fetch,
		instr => instr,
		reg_write => reg_write_from_wb,
		pc_out => pc_from_decode,
		exec_op => execop_from_decode,
		mem_op => memop_from_decode,
		wb_op => wbop_from_decode,
		exc_dec => exc_dec
	);
	
	exec_inst : entity work.exec
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		op => execop_from_decode,
		pc_in => pc_from_decode,
		pc_old_out => pc_old_from_exec,
		pc_new_out => pc_new_from_exec,
		aluresult => aluresult_from_exec,
		wrdata => wrdata,
		zero => zero,
		memop_in => memop_from_decode,
		memop_out => memop_from_exec,
		wbop_in => wbop_from_decode,
		wbop_out => wbop_from_exec,
		exec_op => exec_op,
		reg_write_mem => reg_write_mem,
		reg_write_wr => reg_write_wr
	);
	
	mem_inst : entity work.mem
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		mem_busy => mem_busy_from_mem,
		mem_op => memop_from_exec,
		wbop_in => wbop_from_exec,
		pc_new_in => pc_new_from_exec,
		pc_old_in => pc_old_from_exec,
		aluresult_in => aluresult_from_exec,
		wrdata => wrdata,
		zero => zero,
		reg_write => reg_write_from_mem,
		pc_new_out => pc_new_from_mem,
		pcsrc => pcsrc,
		wbop_out => wbop_from_mem,
		pc_old_out => pc_old_from_mem,
		aluresult_out => aluresult_from_mem,
		memresult => memresult,
		mem_out => mem_d_out,
		mem_in => mem_d_in,
		exc_load => exc_load,
		exc_store => exc_store
	);
	
	wb_inst : entity work.wb
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		op => wbop_from_mem,
		aluresult => aluresult_from_mem,
		memresult => memresult,
		pc_old_in => pc_old_from_mem,
		reg_write => reg_write_from_wb
	);
	
	fwd_inst1 : entity work.fwd
	port map (
		reg_write_mem => reg_write_from_mem,
		reg_write_wb => reg_write_from_wb,
		reg => exec_op.rs1,
		val => reg_write_mem.data,
		do_fwd => reg_write_mem.write
	);
	reg_write_mem.reg <= exec_op.rs1;
	
	fwd_inst2 : entity work.fwd
	port map (
		reg_write_mem => reg_write_from_mem,
		reg_write_wb => reg_write_from_wb,
		reg => exec_op.rs2,
		val => reg_write_wr.data,
		do_fwd => reg_write_wr.write
	);
	reg_write_wr.reg <= exec_op.rs2;
	
--	ctrl_inst : entity work.ctrl_inst
--	port map (
--		clk => clk;
--		res_n => res_n;
--		stall => ;
--		stall_fetch => stall_fetch;
--		stall_dec => stall_dec;
--		stall_exec => stall_exec;
--		stall_mem => stall_mem;
--		stall_wb => stall_wb;
--		flush_fetch => flush_fetch;
--		flush_dec => flush_dec;
--		flush_exec => flush_exec;
--		flush_mem => flush_mem;
--		flush_wb => flush_wb;
--		wb_op_exec => ;
--		exec_op_dec => ;
--		pcsrc_in => ;
--		pcsrc_out => 
--	);

end architecture;
