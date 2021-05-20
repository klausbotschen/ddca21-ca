library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;
use work.memu;

entity mem is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- to Ctrl
		mem_busy      : out std_logic;

		-- from EXEC
		mem_op        : in  mem_op_type; -- branch_type, mem {rd, wr, type(bhw)}
		wbop_in       : in  wb_op_type; -- rd_reg, wr, src_sel
		pc_new_in     : in  pc_type;
		pc_old_in     : in  pc_type;
		aluresult_in  : in  data_type;
		wrdata        : in  data_type;
		zero          : in  std_logic;

		-- to EXEC (forwarding)
		reg_write     : out reg_write_type;

		-- to FETCH
		pc_new_out    : out pc_type;
		pcsrc         : out std_logic;

		-- to WB
		wbop_out      : out wb_op_type;
		pc_old_out    : out pc_type;
		aluresult_out : out data_type;
		memresult     : out data_type;

		-- memory controller interface
		mem_out       : out mem_out_type; -- addr, rd, rw, byteena, wrdata
		mem_in        : in  mem_in_type; -- busy, rddata

		-- exceptions
		exc_load      : out std_logic;
		exc_store     : out std_logic
	);
end entity;

architecture rtl of mem is
	signal mem_op_next : mem_op_type;
	signal wb_next : wb_op_type;
	signal alu_next, wrd_next : data_type;
	signal zero_next : std_logic;
	signal mi_next : mem_in_type;
begin
	
	-- used in exercise IV:
	reg_write.write <= '0';
	reg_write.reg <= (others => '0');
	reg_write.data <= (others => '0');
	
	sync : process(res_n, clk) is 
	begin 
		if(res_n = '0') then
			mem_op_next <= MEM_NOP;
			wb_next <= WB_NOP;
			mi_next <= MEM_IN_NOP;
			wrd_next <= (others => '0');
			alu_next <= (others => '0');
			pc_new_out <= (others => '0');
			pc_old_out <= (others => '0');
		elsif(rising_edge(clk)) then
			if stall = '0' then
				mem_op_next <= mem_op;
				wb_next <= wbop_in;
				pc_new_out <= pc_new_in;
				pc_old_out <= pc_old_in;
				alu_next <= aluresult_in;
				wrd_next <= wrdata;
				zero_next <= zero;
				mi_next <= mem_in;
			else
				mem_op_next.mem.memread <= '0';
				mem_op_next.mem.memwrite <= '0';
			end if;
		end if;
	end process;
	
	async : process(all) is
	begin
		
		pcsrc <= '0';
		aluresult_out <= alu_next;
		
		case mem_op_next.branch is
			when BR_NOP		=>
				pcsrc <= '0';
			when BR_BR		=>
				pcsrc <= '1';
			when BR_CND		=>
				if zero_next = '0' then pcsrc <= '1'; end if;
			when BR_CNDI	=>
				pcsrc <= '1';
				if zero_next = '1' then pcsrc <= '1'; end if;
			when others =>
				pcsrc <= '0';
		end case;
		

		if flush = '1' then
			wbop_out <= WB_NOP;
		else -- regular operation: tunnel through
			wbop_out <= wb_next;
		end if;
	end process;
	
	memu_inst : entity work.memu
	port map (
		op => mem_op_next.mem,
		A => alu_next,		-- ALU calculates address
		W => wrd_next,
		R => memresult,
		B => mem_busy,
		XL => exc_load,
		XS => exc_store,
		D => mi_next,
		M => mem_out
	);

end architecture;
