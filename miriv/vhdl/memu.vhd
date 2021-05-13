library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
	port (
		-- to mem
		op   : in  memu_op_type; -- rd, wr, type(bhw)
		A    : in  data_type; -- address
		W    : in  data_type; -- write data
		R    : out data_type := (others => '0'); -- result of memory load

		B    : out std_logic := '0';  -- busy
		XL   : out std_logic := '0';  -- exception load
		XS   : out std_logic := '0';  -- exception store

		-- to memory controller
		D    : in  mem_in_type; -- busy, rddata
		M    : out mem_out_type := MEM_OUT_NOP -- adr, rd, wr, bena, wrdata
	);
end entity;

architecture rtl of memu is
	signal adex : std_logic;
	signal sign : std_logic;
begin

	B <= D.busy;

	adex <= '1' when (A(0) = '1' and
		(op.memtype = MEM_H or op.memtype = MEM_HU)) or
		(op.memtype = MEM_W and (A(0) = '1' or A(1) = '1')) else '0';

	XL <= '1' when op.memread and adex else '0';
	XS <= '1' when op.memwrite and adex else '0';
	
	M.rd <= op.memread and not adex;
	M.wr <= op.memwrite and not adex;
	M.address <= A(15 downto 2);

	sq_p : process(all)
	begin
		M.wrdata <= (others => '-');
		R <= (others => '0');
		case op.memtype is
			when MEM_B | MEM_BU =>
			case A(1 downto 0) is
				when "00" =>
					M.byteena <= "1000";
					M.wrdata(31 downto 24) <= W(7 downto 0);
					R(7 downto 0) <= D.rddata(31 downto 24);
				when "01" =>
					M.byteena <= "0100";
					M.wrdata(23 downto 16) <= W(7 downto 0);
					R(7 downto 0) <= D.rddata(23 downto 16);
				when "10" =>
					M.byteena <= "0010";
					M.wrdata(15 downto 8) <= W(7 downto 0);
					R(7 downto 0) <= D.rddata(15 downto 8);
				when "11" =>
					M.byteena <= "0001";
					M.wrdata(7 downto 0) <= W(7 downto 0);
					R(7 downto 0) <= D.rddata(7 downto 0);
				when others => null;
			end case;
			sign <= R(7);
			if op.memtype = MEM_B then
				R(31 downto 8) <= (others => sign);
			end if;

			when MEM_H | MEM_HU =>
			case A(1 downto 0) is
				when "00" | "01" =>
					M.byteena <= "1100";
					M.wrdata(31 downto 24) <= W(7 downto 0);
					M.wrdata(23 downto 16) <= W(15 downto 8);
					R(7 downto 0) <= D.rddata(31 downto 24);
					R(15 downto 8) <= D.rddata(23 downto 16);
				when "10" | "11" =>
					M.byteena <= "0011";
					M.wrdata(15 downto 8) <= W(7 downto 0);
					M.wrdata(7 downto 0) <= W(15 downto 8);
					R(7 downto 0) <= D.rddata(15 downto 8);
					R(15 downto 8) <= D.rddata(7 downto 0);
				when others => null;
			end case;
			sign <= R(15);
			if op.memtype = MEM_H then
				R(31 downto 16) <= (others => sign);
			end if;

			when MEM_W =>
				M.byteena <= "1111";
				M.wrdata(31 downto 24) <= W(7 downto 0);
				M.wrdata(23 downto 16) <= W(15 downto 8);
				M.wrdata(15 downto 8) <= W(23 downto 16);
				M.wrdata(7 downto 0) <= W(31 downto 24);
				R(7 downto 0) <= D.rddata(31 downto 24);
				R(15 downto 8) <= D.rddata(23 downto 16);
				R(23 downto 16) <= D.rddata(15 downto 8);
				R(31 downto 24) <= D.rddata(7 downto 0);
		end case;
	end process;


end architecture;
