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
	signal op_next : exec_op_type;
	
	-- ALU
	signal aluA, aluB : data_type;
	
	-- pc-adder
	signal pc_adder_input1, pc_adder_out : pc_type;
	
	signal aluZ : std_logic;
	signal pc_add : pc_type;
begin
	
	-- forwarding data and control purpose in exercise IV, not used in exercise III:
	-- exec_op;
	-- reg_write_mem
	-- reg_write_wr
	
	-- use conditional statement, not selected
	pc_new_out <= std_logic_vector(unsigned(pc_in) + unsigned(pc_add)) when aluZ = '1' else pc_in;
	zero <= aluZ;
	
	-- 1-MUX controlling input data for ALU input A
	aluA	<=	to_data_type(pc_in) when op_next.alusrc2 = '1' else
				op_next.readdata1;
	
	-- 1-MUX controlling input data for ALU input B
	aluB	<=	op_next.imm when op_next.alusrc1 = '1' else
				op_next.readdata2;
	
	-- 1-MUX controlling input data for first input of PC-adder (second input is always connected to op_next.imm)
	pc_adder_input1	<=	to_pc_type(op_next.readdata1) when op_next.alusrc3 = '1' else
								pc_in;
	
	-- PC-adder
	pc_adder_out <= std_logic_vector(unsigned(pc_adder_input1) + unsigned(to_pc_type(op_next.imm)));
	
	-- hard wire LSB of PC-adder output to '0'
	pc_new_out <= pc_adder_out and PC_MASK;
	
	sync : process(res_n, clk) is
	begin 
		if(res_n = '0') then
			op_next <= EXEC_NOP;
		elsif(rising_edge(clk)) then
			op_next <= op;
		end if;
	end process;
	
	async : process(all) is
	begin
		pc_old_out <= pc_in;
		wrdata <= op_next.readdata2;
		
		if flush = '1' then -- flush: write NOPs to subsequent stage
			memop_out <= MEM_NOP;
			wbop_out <= WB_NOP;
		else -- regular operation: tunnel through
			memop_out <= memop_in;
			wbop_out <= wbop_in;
		end if;
	end process;
	
	alu_inst : alu
	port map 
	(
		op => op.aluop,
		A => aluA,
		B => aluB,
		R => aluresult,
		Z => zero
	);
	
end architecture;
