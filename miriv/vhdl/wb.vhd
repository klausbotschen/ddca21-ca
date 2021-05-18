library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity wb is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from MEM
		op         : in  wb_op_type;
		aluresult  : in  data_type;
		memresult  : in  data_type;
		pc_old_in  : in  pc_type;

		-- to FWD and DEC
		reg_write  : out reg_write_type
	);
end entity;

architecture rtl of wb is
	signal op_next : wb_op_type;
	signal aluresult_next : data_type;
	signal memresult_next : data_type;
	signal pc_old_in_next : pc_type;
begin
	
	sync : process(res_n, clk) is 
		-- Declaration(s) 
	begin 
		if(res_n = '0') then
				op_next <= WB_NOP;
				aluresult_next <= (others => '0');
				memresult_next <= (others => '0');
				pc_old_in_next <= (others => '0');
		elsif(rising_edge(clk)) then
			if stall = '0' then
				op_next <= op;
				aluresult_next <= aluresult;
				memresult_next <= memresult;
				pc_old_in_next <= pc_old_in;
			end if;
			if flush = '1' then
				op_next <= WB_NOP;
			end if;
		end if;
	end process;
	
	async : process(all) is
		-- Declaration(s)
	begin
		reg_write.write <= op_next.write;
		reg_write.reg <= op_next.rd;
		case op_next.src is
			when WBS_ALU =>
				reg_write.data <= aluresult_next;
			when WBS_MEM =>
				reg_write.data <= memresult_next;
			when WBS_OPC =>
				reg_write.data <= to_data_type(pc_old_in_next);
		end case;
	end process;
	
end architecture;
