library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

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
	signal op_next : exec_op_type;
	signal aluA, aluB : data_type;
	signal aluZ : std_logic;
	signal pc_add : pc_type;
begin
	
	-- forwarding data and control purpose in exercise IV, not used in exercise III:
	exec_op <= (others => '0');
	-- reg_write_mem
	-- reg_write_wr
	
	-- if branch instruction
	-- TODO
	pc_new_out <= std_logic_vector(unsigned(pc_in) + unsigned(pc_add)) when aluZ = '1' else pc_in;
	zero <= aluZ;
	
	
	sync : process(res_n, clk) is 
		-- Declaration(s) 
	begin 
		if(res_n = '0') then
			-- Asynchronous Sequential Statement(s) 
		elsif(rising_edge(clk)) then
			op_next <= op;
		end if;
	end process;
	
	async : process(all) is
		-- Declaration(s)
	begin
		pc_new_out <= pc_in; -- if no branch is taken
		
		-- TODO
		case op_next.alusrc1 & op_next.alusrc2 & op_next.alusrc3 is
			when "000" =>
				aluA <= op.rddata1;
				aluB <= op.rddata2;
				wrdata <= aluresult;
			when "001" =>
				aluA <= op.rddata1;
				aluB <= op.rddata2;
				
			when "010" =>
				aluA <= op.rddata1;
				aluB <= op.imm;
				wrdata <= aluresult;
			when "011" =>
				aluA <= op.rddata1;
				aluB <= op.imm;
				
			when "100" =>
				aluA <= op.imm;
				aluB <= op.rddata2;
				wrdata <= aluresult;
			when "101" =>
				aluA <= op.imm;
				aluB <= op.rddata2;
				
			when "110" =>
				aluA <= op.imm;
				aluB <= op.imm;
				wrdata <= aluresult;
			when "111" =>
				aluA <= op.imm;
				aluB <= op.imm;
				
		end case;
		
		pc_old_out <= pc_in;
		
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
		Z => aluZ
	);
	
end architecture;
