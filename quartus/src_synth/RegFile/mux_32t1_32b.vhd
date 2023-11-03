-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux_32t1_32b.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 32 bit wide 32:1
-- mux 
--
--
-- NOTES:
-- 1/31/2023 Created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity mux_32t1_32b is
    port (
        i_S : in std_logic_vector(4 downto 0);
        i_D : in word_array(31 downto 0); --32, 32 bit widestd_logic_vectors w
        o_O : out std_logic_vector(31 downto 0));
end mux_32t1_32b;

architecture dataflow of mux_32t1_32b is

begin
    o_O <= i_D(to_integer(unsigned(i_S)));
end dataflow;