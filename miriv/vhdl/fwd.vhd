library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity fwd is
	port (
		-- from Mem
		reg_write_mem : in reg_write_type;

		-- from WB
		reg_write_wb  : in reg_write_type;

		-- from/to EXEC
		reg    : in  reg_adr_type;
		val    : out data_type;
		do_fwd : out std_logic
	);
end entity;

architecture rtl of fwd is
begin
	
	async : process(all) is
		-- Declaration(s)
	begin
		val <= (others => '0');
		do_fwd <= '0';
		
		if reg = reg_write_mem.reg and reg_write_mem.write = '1' then
			val <= reg_write_mem.data;
			do_fwd <= '1';
		elsif reg = reg_write_wb.reg and reg_write_wb.write = '1' then
			val <= reg_write_wb.data;
			do_fwd <= '1';
		end if;
	end process;
	
end architecture;
