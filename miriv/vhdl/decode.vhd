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

	function imm_b(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (11 => inst(7),
						10 downto 5 => inst(30 downto 25),
						4 downto 1 => inst(24 downto 21),
						0 => '0',
						others => inst(31));
		return imm;
	end function;

	function imm_u(inst : data_type) return data_type is
		variable imm : data_type;
	begin
		imm := (31 => inst(31),
						30 downto 20 => inst(30 downto 20),
						19 downto 12 => inst(19 downto 12),
						others => '0');
		return imm;
	end function;

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
	signal imm : data_type;

begin

	-- --------------------------------------------
	regfile_inst : entity work.regfile
	port map (
		clk        => clk,
		res_n      => res_n,
		stall      => stall,
		rdaddr1    => rs1,
		rdaddr2    => rs2,
		rddata1    => exec_op.readdata1,
		rddata2    => exec_op.readdata2,
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
		exec_op.imm <= imm;
		exec_op.aluop <= ALU_NOP;
		exec_op.alusrc1 <= '0'; -- alu mux, 0: rs2, 1: imm
		exec_op.alusrc2 <= '0'; -- 1: use pc adder
		exec_op.alusrc3 <= '0'; -- branch on 0/1
		wb_op.rd <= rd;

		imm <= imm_i(inst);

		case inst(6 downto 0) is
			when "0000011" => -- LOAD
			when "0100011" => -- STORE
				imm <= imm_s(inst);
			when "1100011" => -- BRANCH
				imm <= imm_b(inst);
				exec_op.alusrc2 <= '1'; -- add imm to pc
				case func3 is
					when "000" => -- BEQ rs1,rs2,imm
						exec_op.aluop <= ALU_SUB; -- use Z bit
					when "001" => -- BNE rs1,rs2,imm
						exec_op.alusrc3 <= '1';
						exec_op.aluop <= ALU_SUB; -- use Z bit
					when "100" => -- BLT rs1,rs2,imm
					when "101" => -- BGE rs1,rs2,imm
					when "110" => -- BLTU rs1,rs2,imm
					when "111" => -- BGEU rs1,rs2,imm
					when others =>
						exc_dec <= '1';
				end case;
			when "1100111" => -- JALR
			when "1101111" => -- JAL
				imm <= imm_j(inst);
			when "0010011" => -- OP_IMM
				exec_op.alusrc1 <= '1';
				case func3 is
					when "000" => -- ADDI rd,rs1,imm
						exec_op.aluop <= ALU_ADD;
					when "001" => -- SLLI † rd,rs1,shamt
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
			when "0010111" => -- AUIPC
				imm <= imm_u(inst);
			when "0110111" => -- LUI
				imm <= imm_u(inst);
			when "0001111" => -- FENCE = nop
			when others =>
				exc_dec <= '1';
		end case;
	end process;

end architecture;
