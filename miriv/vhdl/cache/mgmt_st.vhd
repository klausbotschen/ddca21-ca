library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st is
	generic (
		SETS_LD  : natural := SETS_LD;
		WAYS_LD  : natural := WAYS_LD
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		index : in c_index_type;
		wrv   : in std_logic; -- write valid bit
		wr    : in std_logic; -- write dirty+data
		rd    : in std_logic;

		valid_in    : in std_logic;
		dirty_in    : in std_logic;
		tag_in      : in c_tag_type;
		way_out     : out c_way_type;
		valid_out   : out std_logic;
		dirty_out   : out std_logic;
		tag_out     : out c_tag_type;
		hit_out     : out std_logic
	);
end entity;

architecture impl of mgmt_st is
	signal entry_w, entry_r : c_mgmt_info;
begin
	storage_inst : entity work.mgmt_st_1w(impl)
		generic map (
			SETS_LD => SETS_LD
		)
		port map (
			clk     => clk,
			res_n   => res_n,
			index   => index,
			wrv     => wrv, -- write valid bit
			we      => wr, -- write dirty+data
			mgmt_info_in  => entry_w,
			mgmt_info_out => entry_r
		);

	entry_w.valid <= valid_in;
	entry_w.dirty <= dirty_in;
	entry_w.replace <= '0';
	entry_w.tag <= tag_in;

	way_out <= (others => '0');
	valid_out <= entry_r.valid;
	dirty_out <= entry_r.dirty;
	tag_out <= entry_r.tag;

	hit_out <= '1' when rd = '1'
				and valid_out = '1'
				and tag_out = tag_in
				else '0';

end architecture;
