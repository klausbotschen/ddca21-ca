library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.single_clock_rw_ram_pkg.all;

entity data_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk       : in std_logic;

		we        : in std_logic;
		rd        : in std_logic;
		index     : in c_index_type;
		byteena   : in mem_byteena_type;

		data_in   : in mem_data_type;
		data_out  : out mem_data_type
);
end entity;

architecture impl of data_st_1w is
begin
end architecture;
