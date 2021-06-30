library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
	port (
		clk         : in std_logic;
		res_n       : in std_logic;
		stall       : in std_logic;

		stall_fetch : out std_logic;
		stall_dec   : out std_logic;
		stall_exec  : out std_logic;
		stall_mem   : out std_logic;
		stall_wb    : out std_logic;

		flush_fetch : out std_logic;
		flush_dec   : out std_logic;
		flush_exec  : out std_logic;
		flush_mem   : out std_logic;
		flush_wb    : out std_logic;

		-- from FWD
		wb_op_exec  : in  wb_op_type;
		exec_op_dec : in  exec_op_type;

		pcsrc_in : in std_logic;
		pcsrc_out : out std_logic
	);
end entity;

architecture rtl of ctrl is
	signal read_stall : std_logic;
	type STATE_TYPE is (s0, s1, s2);
	signal state, state_next : STATE_TYPE;
	signal wb_op_exec_next : wb_op_type;
	signal exec_op_dec_next : exec_op_type;
	signal pcsrc_in_next : std_logic;
	signal read_stall_fetch : std_logic;
	signal read_stall_dec : std_logic;
	signal read_stall_exec : std_logic;
	signal flush_exec_read_stall : std_logic;
	signal flush_mem_read_stall : std_logic;
begin
	
	flush_fetch <= '1' when pcsrc_in = '1' else '0';
	flush_dec <= '1' when pcsrc_in = '1' else '0';
	flush_exec <= '1' when pcsrc_in = '1' or flush_exec_read_stall = '1' else '0';
	flush_mem <= '1' when flush_mem_read_stall = '1' else '0';
	flush_wb <= '0';
	
	stall_fetch <= '1' when stall = '1' or read_stall_fetch = '1' else '0';
	stall_dec <= '1' when stall = '1' or read_stall_dec = '1' else '0';
	stall_exec <= '1' when stall = '1' or read_stall_exec = '1' else '0';
	stall_mem <= stall;
	stall_wb <= stall;
	
	pcsrc_out <= pcsrc_in;
	
	-- check for fwd condition, reg not zero, writing operation and no branch
	read_stall <= '1' when ((exec_op_dec_next.rs1 = wb_op_exec_next.rd) or (exec_op_dec_next.rs2 = wb_op_exec_next.rd))
									and (wb_op_exec_next.rd /= ZERO_REG)
									and (wb_op_exec_next.src = WBS_MEM)
									and (pcsrc_in_next /= '1')
						else '0';
	
	sync : process(clk, res_n) is
	begin
		if res_n = '0' then
			state <= s0;
			wb_op_exec_next <= WB_NOP;
			exec_op_dec_next <= EXEC_NOP;
			pcsrc_in_next <= '0';
		elsif (rising_edge(clk)) then
			state <= state_next;
			wb_op_exec_next <= wb_op_exec;
			exec_op_dec_next <= exec_op_dec;
			pcsrc_in_next <= pcsrc_in;
		end if;
	end process;
	
	async : process(all) is
		-- Declaration(s)
	begin
		read_stall_fetch <= '0';
		read_stall_dec <= '0';
		read_stall_exec <= '0';
		flush_mem_read_stall <= '0';
		flush_exec_read_stall <= '0';
		state_next <= state;
		
		case state is
			when s0 =>
				if read_stall = '1' then
					state_next <= s1;
				end if;
			when s1 =>
				read_stall_fetch <= '1';
				read_stall_dec <= '1';
				read_stall_exec <= '1';
				if stall = '0' then
					state_next <= s2;
				end if;
			when s2 =>
				flush_mem_read_stall <= '1';
				state_next <= s0;
		end case;
	end process;
	
end architecture;
