library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk     : in std_logic;
		res_n   : in std_logic;

		index   : in c_index_type;
		we      : in std_logic; -- write dirty+data
		wrv     : in std_logic; -- write valid bit

		mgmt_info_in  : in c_mgmt_info;
		mgmt_info_out : out c_mgmt_info
	);
end entity;

architecture impl of mgmt_st_1w is
	type MEM is array(0 TO (2**SETS_LD)-1) of c_tag_type;
	signal tmem : MEM := (others => (others => '0'));

	type CREG is array(0 TO (2**SETS_LD)-1) of std_logic;
	type VREG is array(0 TO (2**SETS_LD)-1) of std_logic;
	signal valreg : CREG := (others => '0');
	signal dirtreg : CREG := (others => '0');
begin

	-- asynchronous read
	mgmt_info_out.valid <= valreg(to_integer(unsigned(index)));
	mgmt_info_out.dirty <= dirtreg(to_integer(unsigned(index)));
	mgmt_info_out.replace <= '0';
	mgmt_info_out.tag <= tmem(to_integer(unsigned(index)));

	-- use registers, the FPGA only has synchronous RAM nodes
	vbit_p: process(clk, res_n)
	begin
		if res_n = '0' then
		  valreg <= (others => '0');
		  dirtreg <= (others => '0');
		elsif rising_edge(clk) then
			if we = '1' then
				dirtreg(to_integer(unsigned(index))) <= mgmt_info_in.dirty;
				tmem(to_integer(unsigned(index))) <= mgmt_info_in.tag;
			end if;
			if wrv = '1' then
				valreg(to_integer(unsigned(index))) <= mgmt_info_in.valid;
			end if;
		end if;
	end process;

end architecture;
