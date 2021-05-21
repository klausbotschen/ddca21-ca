library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;

entity regfile is
	port (
		clk              : in  std_logic;
		res_n            : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  reg_adr_type;
		rddata1, rddata2 : out data_type;
		wraddr           : in  reg_adr_type;
		wrdata           : in  data_type;
		regwrite         : in  std_logic
	);
end entity;

architecture rtl of regfile is
	signal rda1nx, rda2nx : natural range 2**REG_BITS-1 downto 0 := 0;
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**REG_BITS-1 downto 0) of word_t;
	signal ram : memory_t := (others => (others => '0'));
begin

	sync: process(clk, res_n)
	begin
	if res_n = '0' then
		rda1nx <= 0;
		rda2nx <= 0;
	elsif(rising_edge(clk)) then
		if stall = '0' then
			rda1nx <= to_integer(unsigned(rdaddr1));
			rda2nx <= to_integer(unsigned(rdaddr2));
			if regwrite = '1' and unsigned(wraddr) > 0 then
				ram(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
		end if;
	end if;
	end process;

	async: process(all)
	begin
		rddata1 <= ram(rda1nx);
		rddata2 <= ram(rda2nx);
		if rda1nx = 0 then
			rddata1 <= (others => '0');
		elsif rda1nx = to_integer(unsigned(wraddr))
				and stall = '0' then
			rddata1 <= wrdata;
		end if;
		if rda2nx = 0 then
			rddata2 <= (others => '0');
		elsif rda2nx = to_integer(unsigned(wraddr))
				and stall = '0' then
			rddata2 <= wrdata;
		end if;
	end process;

end architecture;
