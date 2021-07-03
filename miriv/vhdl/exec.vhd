library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.alu;

entity exec is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- from DEC
		op            : in  exec_op_type;
		pc_in         : in  pc_type;

		-- to MEM
		pc_old_out    : out pc_type;
		pc_new_out    : out pc_type;
		aluresult     : out data_type;
		wrdata        : out data_type;
		zero          : out std_logic;

		memop_in      : in  mem_op_type;
		memop_out     : out mem_op_type;
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type;

		-- FWD
		exec_op       : out exec_op_type;
		reg_write_mem : in  reg_write_type;
		reg_write_wr  : in  reg_write_type
	);
end entity;

architecture rtl of exec is
	
	constant PC_MASK : pc_type := (	0 => '0',
												others => '1');
	
	-- next ALU operation data from previous stage
	signal op_next : exec_op_type := EXEC_NOP;
	
	-- ALU
	signal aluA, aluB : data_type := (others => '0');
	
	-- pc-adder
	signal pco_next, pc_adder_input1, pc_adder_out : pc_type := (others => '0');
	
	--fwd
	signal readdata1, readdata2: data_type;
	signal fwd1, fwd2 : std_logic;
	
	signal mop_next : mem_op_type;
	signal wb_next : wb_op_type;
begin
	
	fwd_inst1 : entity work.fwd
	port map (
		reg_write_mem => reg_write_mem,
		reg_write_wb => reg_write_wr,
		reg => op_next.rs1,
		val => readdata1,
		do_fwd => fwd1
	);
	
	fwd_inst2 : entity work.fwd
	port map (
		reg_write_mem => reg_write_mem,
		reg_write_wb => reg_write_wr,
		reg => op_next.rs2,
		val => readdata2,
		do_fwd => fwd2
	);

	-- forwarding data and control purpose in exercise IV, not used in exercise III:
	exec_op <= op_next;
	
	-- MUX controlling input data for ALU input A
	aluA <= to_data_type(pco_next) when op_next.alusrc2 = '1'
				else readdata1 when fwd1 = '1'
				else op_next.readdata1;
	
	-- MUX controlling input data for ALU input B
	aluB <= op_next.imm when op_next.alusrc1 = '1'
				else readdata2 when fwd2 = '1'
				else op_next.readdata2;
	
	-- MUX controlling input data for first input of PC-adder (second input is always connected to op_next.imm)
	pc_adder_input1 <= pco_next when op_next.alusrc3 = '0'
				else to_pc_type(readdata1) when fwd1 = '1'
				else to_pc_type(op_next.readdata1);
	
	-- PC-adder
	pc_adder_out <= std_logic_vector(unsigned(pc_adder_input1) + unsigned(to_pc_type(op_next.imm)));
	
	-- hard wire LSB of PC-adder output to '0'
	pc_new_out <= pc_adder_out and PC_MASK;

	sync : process(res_n, clk) is
	begin 
		if(res_n = '0') then
			op_next <= EXEC_NOP;
			pco_next <= (others => '0');
			mop_next <= MEM_NOP;
			wb_next <= WB_NOP;
		elsif(rising_edge(clk)) then
			if stall = '0' then
				op_next <= op;
				pco_next <= pc_in;
				mop_next <= memop_in;
				wb_next <= wbop_in;
			end if;
		end if;
	end process;
	
	wrdata <= op_next.readdata2 when fwd2 = '0' else readdata2;
	
	async : process(all) is
	begin
		pc_old_out <= pco_next;
		
		if flush = '1' then -- flush: write NOPs to subsequent stage
			memop_out <= MEM_NOP;
			wbop_out <= WB_NOP;
		else -- regular operation: tunnel through
			memop_out <= mop_next;
			wbop_out <= wb_next;
		end if;
	end process;
	
	alu_inst : entity work.alu
	port map (
		op => op_next.aluop,
		A => aluA,
		B => aluB,
		R => aluresult,
		Z => zero
	);
	
end architecture;
