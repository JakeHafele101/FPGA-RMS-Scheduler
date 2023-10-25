-- o_Quartus Prime VHDL Template
-- Single-port RAM with single read/write i_ADDRess

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is

	generic (
		DATA_WIDTH : natural := 32; -- Width of bits for each i_ADDRess
		ADDR_WIDTH : natural := 10 -- Width of i_ADDRess as (2^ADDR_WIDTH) - 1
	);
	port (
		i_CLK  : in std_logic;
		i_ADDR : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
		i_DATA : in std_logic_vector((DATA_WIDTH - 1) downto 0);
		i_WE   : in std_logic := '1';
		o_Q    : out std_logic_vector((DATA_WIDTH - 1) downto 0)
	);

end dmem;

architecture rtl of dmem is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
	type memory_t is array((2 ** ADDR_WIDTH) - 1 downto 0) of word_t;

	-- Declare the RAM signal and specify a default value.	quartus Prime
	-- will load the provided memory initialization file (.mif).
	signal ram : memory_t;

begin

	process (i_CLK)
	begin
		if (rising_edge(i_CLK)) then
			if (i_WE = '1') then
				ram(to_integer(unsigned(i_ADDR))) <= i_DATA;
			end if;
		end if;
	end process;

	o_Q <= ram(to_integer(unsigned(i_ADDR)));

end rtl;