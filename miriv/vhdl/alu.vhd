library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

-- ATTENTION: zero flag is only valid on SUB and SLT(U)

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  data_type;
		R    : out data_type := (others => '0');
		Z    : out std_logic := '0'
	);
end alu;

architecture rtl of alu is
begin
	alu_p: process(all)
		variable shiftby : natural;
	begin
		Z <= '-';
		case op is
			when ALU_NOP =>
				R <= B;
			when ALU_SLT =>
				R(R'high-1 downto 1) <= (others => '0');
				R(0) <= '1' when signed(A) < signed(B) else '0';
				Z <= not R(0);
			when ALU_SLTU =>
				R(R'high-1 downto 1) <= (others => '0');
				R(0) <= '1' when unsigned(A) < unsigned(B) else '0';
				Z <= not R(0);
			when ALU_SLL => -- A sll B(4 downto 0)
				shiftby := to_integer(unsigned(B(4 downto 0)));
				R <= std_logic_vector(shift_left(unsigned(A), shiftby));
			when ALU_SRL => -- A srl B(4 downto 0)
				shiftby := to_integer(unsigned(B(4 downto 0)));
				R <= std_logic_vector(shift_right(unsigned(A), shiftby));
			when ALU_SRA => -- A sra B(4 downto 0)
				shiftby := to_integer(unsigned(B(4 downto 0)));
				R <= std_logic_vector(shift_right(signed(A), shiftby));
			when ALU_ADD =>
				R <= std_logic_vector(signed(A) + signed(B));
			when ALU_SUB =>
				if A = B then Z <= '1'; else Z <= '0'; end if;
				R <= std_logic_vector(signed(A) - signed(B));
			when ALU_AND =>
				R <= A and B;
			when ALU_OR =>
				R <= A or B;
			when ALU_XOR =>
				R <= A xor B;
		end case;
	end process;
end architecture;
