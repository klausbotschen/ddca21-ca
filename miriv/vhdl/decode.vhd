library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity decode is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from fetch
		pc_in      : in  pc_type;
		instr      : in  instr_type;

		-- from writeback
		-- write, reg, data
		reg_write  : in reg_write_type;

		-- towards next stages
		pc_out     : out pc_type;
		 -- alu {op, src1-3}, rs1-2, readdata1-2, imm
		exec_op    : out exec_op_type;
		 -- branch, mem {memread, memwrite, memtype}
		mem_op     : out mem_op_type;
		 -- rd, write, src
		wb_op      : out wb_op_type;

		-- exceptions
		exc_dec    : out std_logic
	);
end entity;

architecture rtl of decode is

	-- --------------------------------------------
	function imm_i(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (10 downto 5 => inst(30 downto 25),
						4 downto 1 => inst(24 downto 21),
						0 => inst(20),
						others => inst(31));
		return imm;
	end function;

	function imm_s(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (10 downto 5 => inst(30 downto 25),
						4 downto 1 => inst(11 downto 8),
						0 => inst(7),
						others => inst(31));
		return imm;
	end function;

	-- including << 1
	function imm_b(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (11 => inst(7),
						10 downto 5 => inst(30 downto 25),
						4 downto 1 => inst(11 downto 8),
						0 => '0',
						others => inst(31));
		return imm;
	end function;

	-- including << 12
	function imm_u(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (31 => inst(31),
						30 downto 20 => inst(30 downto 20),
						19 downto 12 => inst(19 downto 12),
						others => '0');
		return imm;
	end function;

	-- including << 1
	function imm_j(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (19 downto 12 => inst(19 downto 12),
						11 => inst(20),
						10 downto 5 => inst(30 downto 25),
						4 downto 1 => inst(24 downto 21),
						0 => '0',
						others => inst(31));
		return imm;
	end function;
	-- --------------------------------------------

	signal rs1, rs2, rd : reg_adr_type;
	signal inst : instr_type;
	signal imm, rd1, rd2 : data_type;

begin

	-- --------------------------------------------
	regfile_inst : entity work.regfile
	port map (
		clk        => clk,
		res_n      => res_n,
		stall      => stall,
		rdaddr1    => rs1,
		rdaddr2    => rs2,
		rddata1    => rd1,
		rddata2    => rd2,
		wraddr     => reg_write.reg,
		wrdata     => reg_write.data,
		regwrite   => reg_write.write
	);
	-- --------------------------------------------

sync: process(clk, res_n) is
	begin
		if res_n = '0' then
			inst <= NOP_INST;
		elsif rising_edge(clk) then
			if flush = '1' then
				inst <= NOP_INST;
			end if;
			if stall = '0' then
				pc_out <= pc_in;
				inst <= instr;
			end if;
		end if;
	end process;


	async: process(all) is
		variable func3 : std_logic_vector(2 downto 0);
		variable func37 : std_logic_vector(9 downto 0);
	begin
		func3 := inst(14 downto 12);
		func37(9 downto 7) := inst(14 downto 12);
		func37(6 downto 0) := inst(31 downto 25);
		rs1 <= inst(19 downto 15);
		rs2 <= inst(24 downto 20);
		rd <= inst(11 downto 7);
		exec_op.rs1 <= rs1;
		exec_op.rs2 <= rs2;
		exec_op.readdata1 <= rd1;
		exec_op.readdata2 <= rd2;
		exec_op.imm <= imm;
		exec_op.aluop <= ALU_NOP;
		exec_op.alusrc1 <= '0'; -- alu B mux, 0: rs2, 1: imm
		exec_op.alusrc2 <= '0'; -- alu A mux, 0: rs1, 1: pc (AUIPC)
		exec_op.alusrc3 <= '0'; -- PC adder mux, 0: PC+imm, 1: rs1+imm (JALR)
		-- note, after the PC adder bit 0 shall be hard wired to '0'!
		mem_op.branch <= BR_NOP; -- set pcscr<='1' when branch
		mem_op.mem <= MEMU_NOP;
		wb_op <= WB_NOP;
		exc_dec <= '0';

		imm <= imm_i(inst); -- load, op_imm, jarl

		case inst(6 downto 0) is
			when "0110111" => -- LUI: rd=imm<<12
				imm <= imm_u(inst); -- imm<<12
				exec_op.alusrc1 <= '1'; -- ALU-B <= imm
				exec_op.aluop <= ALU_NOP; -- select B
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
			when "0010111" => -- AUIPC: rd=pc+(imm<<12)
				imm <= imm_u(inst); -- imm<<12
				exec_op.alusrc1 <= '1'; -- ALU-B <= imm
				exec_op.alusrc2 <= '1'; -- ALU-A <= PC
				exec_op.aluop <= ALU_ADD; -- rd=pc+imm
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
			when "1101111" => -- JAL: rd=pc+4; pc=pc+(imm<<1)
				imm <= imm_j(inst); -- imm<<1
				mem_op.branch <= BR_BR; -- pcsrc <= '1'
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_OPC; -- old PC+4
			when "1100111" => -- JALR
				case func3 is
					when "000" => -- JALR: rd=pc+4; pc=imm+rs1; pc[0]=’0’
						exec_op.alusrc3 <= '1'; -- pc(0)<='0'
						mem_op.branch <= BR_BR; -- pcsrc <= '1'
						wb_op.rd <= rd;
						wb_op.write <= '1';
						wb_op.src <= WBS_OPC; -- old PC+4
					when others =>
						exc_dec <= '1';
				end case;
			when "1100011" => -- BRANCH: pc=pc+(imm<<1)
				imm <= imm_b(inst); -- imm<<1
				mem_op.branch <= BR_CND; -- pcsrc <= '1'
				case func3 is
					when "000" => -- BEQ rs1,rs2,imm
						exec_op.aluop <= ALU_SUB; -- jump when Z = '0'
					when "001" => -- BNE rs1,rs2,imm
						mem_op.branch <= BR_CNDI;
						exec_op.aluop <= ALU_SUB; -- jump when Z = '1'
					when "100" => -- BLT rs1,rs2,imm (signed)
						exec_op.aluop <= ALU_SLT; -- jump when Z = '0'
					when "101" => -- BGE rs1,rs2,imm (signed)
						mem_op.branch <= BR_CNDI;
						exec_op.aluop <= ALU_SLT; -- jump when Z = '1'
					when "110" => -- BLTU rs1,rs2,imm (unsigned)
						exec_op.aluop <= ALU_SLTU; -- jump when Z = '0'
					when "111" => -- BGEU rs1,rs2,imm (unsigned)
						mem_op.branch <= BR_CNDI;
						exec_op.aluop <= ALU_SLTU; -- jump when Z = '1'
					when others =>
						exc_dec <= '1';
				end case;
			when "0000011" => -- LOAD
				exec_op.alusrc1 <= '1'; -- ALU-B <= imm
				exec_op.aluop <= ALU_ADD; -- rd=rs1+imm
				mem_op.mem.memread <= '1';
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_MEM;
				case func3 is
					when "000" => -- LB rd,rs1,imm
						mem_op.mem.memtype <= MEM_B;
					when "001" => -- LH rd,rs1,imm
						mem_op.mem.memtype <= MEM_H;
					when "010" => -- LW rd,rs1,imm
						mem_op.mem.memtype <= MEM_W;
					when "100" => -- LBU rd,rs1,imm
						mem_op.mem.memtype <= MEM_BU;
					when "101" => -- LHU rd,rs1,imm
						mem_op.mem.memtype <= MEM_HU;
					when others =>
						exc_dec <= '1';
				end case;
			when "0100011" => -- STORE
				imm <= imm_s(inst);
				exec_op.alusrc1 <= '1'; -- ALU-B <= imm
				exec_op.aluop <= ALU_ADD; -- rd=rs1+imm
				mem_op.mem.memwrite <= '1';
				case func3 is
					when "000" => -- SB rs1,rs2,imm
						mem_op.mem.memtype <= MEM_B;
					when "001" => -- SH rs1,rs2,imm
						mem_op.mem.memtype <= MEM_H;
					when "010" => -- SW rs1,rs2,imm
						mem_op.mem.memtype <= MEM_W;
					when others =>
						exc_dec <= '1';
				end case;
			when "0010011" => -- OP_IMM
				exec_op.alusrc1 <= '1'; -- ALU-B <= imm
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				case func3 is
					when "000" => -- ADDI rd,rs1,imm
						exec_op.aluop <= ALU_ADD;
					when "001" => -- SLLI rd,rs1,shamt
						exec_op.aluop <= ALU_SLL;
					when "010" => -- SLTI rd,rs1,imm
						exec_op.aluop <= ALU_SLT;
					when "011" => -- SLTIU rd,rs1,imm
						exec_op.aluop <= ALU_SLTU;
					when "100" => -- XORI rd,rs1,imm
						exec_op.aluop <= ALU_XOR;
					when "101" =>
						if imm(10) = '0' then -- SRLI rd,rs1,shamt
							exec_op.aluop <= ALU_SRL;
						else                  -- SRAI rs,rs1,shamt
							exec_op.aluop <= ALU_SRA;
						end if;
					when "110" => -- ORI rd,rs1,imm
						exec_op.aluop <= ALU_OR;
					when "111" => -- ANDI rd,rs1,imm
						exec_op.aluop <= ALU_AND;
					when others =>
						exc_dec <= '1';
				end case;
			when "0110011" => -- OP
				wb_op.rd <= rd;
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				case func37 is
					when "0000000000" => -- ADD rd,rs1,rs2
						exec_op.aluop <= ALU_ADD;
					when "0000100000" => -- SUB rd,rs1,rs2
						exec_op.aluop <= ALU_SUB;
					when "0010000000" => -- SLL rd,rs1,rs2
						exec_op.aluop <= ALU_SLL;
					when "0100000000" => -- SLT rd,rs1,rs2
						exec_op.aluop <= ALU_SLT;
					when "0110000000" => -- SLTU rd,rs1,rs2
						exec_op.aluop <= ALU_SLTU;
					when "1000000000" => -- XOR rd,rs1,rs2
						exec_op.aluop <= ALU_XOR;
					when "1010000000" => -- SRL rd,rs1,rs2
						exec_op.aluop <= ALU_SRL;
					when "1010100000" => -- SRA rd,rs1,rs2
						exec_op.aluop <= ALU_SRA;
					when "1100000000" => -- OR rd,rs1,rs2
						exec_op.aluop <= ALU_OR;
					when "1110000000" => -- AND rd,rs1,rs2
						exec_op.aluop <= ALU_AND;
					when others =>
						exc_dec <= '1';
				end case;
			when "0001111" => -- FENCE = nop
				null;
			when others =>
				exc_dec <= '1';
		end case;
	end process;

end architecture;
