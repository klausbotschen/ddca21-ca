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
		we      : in std_logic;
		we_repl	: in std_logic;

		mgmt_info_in  : in c_mgmt_info;
		mgmt_info_out : out c_mgmt_info
	);
end entity;

architecture impl of mgmt_st_1w is
	type MEM is array(0 TO (2**SETS_LD)-1) of c_tag_type;
	signal tmem : MEM := (others => (others => '0'));

	type c_linfo_t is record
		valid : std_logic;
		dirty : std_logic;
	end record;
	constant C_LINE_N : c_linfo_t := (
		valid   => '0',
		dirty   => '0'
	);
	type CREG is array(0 TO (2**SETS_LD)-1) of c_linfo_t;
	signal linereg : CREG := (others => C_LINE_N);
	signal cli_r, cli_w : c_linfo_t;
begin

	-- read
	cli_r <= linereg(to_integer(unsigned(index)));
	mgmt_info_out.valid <= cli_r.valid;
	mgmt_info_out.dirty <= cli_r.dirty;
	mgmt_info_out.replace <= '0';
	mgmt_info_out.tag <= tmem(to_integer(unsigned(index)));
	-- write
	cli_w.valid <= mgmt_info_in.valid;
	cli_w.dirty <= mgmt_info_in.dirty;

	-- use registers for valid an dirty bit
	vbit_p: process(clk, res_n)
	begin
		if res_n = '0' then
		  linereg <= (others => C_LINE_N);
		elsif rising_edge(clk) then
			if we = '1' then
				linereg(to_integer(unsigned(index))) <= cli_w;
			end if;
		end if;
	end process;

	-- use sram for tag info
	rmem_p: process(clk)
	begin
		if rising_edge(clk) then
			if we = '1' then
				tmem(to_integer(unsigned(index))) <= mgmt_info_in.tag;
			end if;
		end if;
	end process;

end architecture;
