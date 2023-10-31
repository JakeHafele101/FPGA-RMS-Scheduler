-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux_8t1_32b.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 32 bit wide 8:1 MUX
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_8t1_32b is
    port (
        i_S  : in std_logic_vector(2 downto 0);
        i_D0 : in std_logic_vector(31 downto 0);
        i_D1 : in std_logic_vector(31 downto 0);
        i_D2 : in std_logic_vector(31 downto 0);
        i_D3 : in std_logic_vector(31 downto 0);
        i_D4 : in std_logic_vector(31 downto 0);
        i_D5 : in std_logic_vector(31 downto 0);
        i_D6 : in std_logic_vector(31 downto 0);
        i_D7 : in std_logic_vector(31 downto 0);
        o_O  : out std_logic_vector(31 downto 0));
end mux_8t1_32b;

architecture dataflow of mux_8t1_32b is

begin
    with (i_S) select
    o_O <=  i_D0 when "000", 
            i_D1 when "001", 
            i_D2 when "010",
            i_D3 when "011", 
            i_D4 when "100",
            i_D5 when "101", 
            i_D6 when "110",
            i_D7 when "111",
           X"00000000" when others;
end dataflow;