-- o_Quartus Prime VHDL Template
-- Single-port RAM with single read/write i_ADDRess

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extend_16t32 is
	port (
		i_A          : in std_logic_vector(15 downto 0); --16 bit input
		i_nZero_Sign : in std_logic := '1';              --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
		o_F          : out std_logic_vector(31 downto 0) --32 bit output
	);

end extend_16t32;

architecture dataflow of extend_16t32 is

	signal s_Sel : std_logic_vector(1 downto 0);
	signal s_F_Upper : std_logic_vector(15 downto 0);

begin

	-- select line for case statement is between control input i_nZero_Sign and MSB of i_A
	s_Sel <= i_nZero_Sign & i_A(15);

	with (s_Sel) select
		s_F_Upper <= X"0000" when "00",
		             X"0000" when "01",
					 X"0000" when "10",
					 X"FFFF" when "11",
					 X"0000" when others;

	-- Append s_F_Upper to upper word of o_F, and i_A as lower word
	o_F <= s_F_Upper & i_A;

end dataflow;