-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- full_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 1 bit full
-- adder that takes in 2 1 bit inputs and a carry in, and outputs 1 
-- sum bit and a carry out bit. This module can be used for an N bit 
-- ripple carry adder. It is also implemented structurally.
-- 
-- Created 1/22/2023 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    port (
        i_X    : in std_logic;
        i_Y    : in std_logic;
        i_Cin  : in std_logic;
        o_S    : out std_logic;
        o_Cout : out std_logic);
end full_adder;

architecture behavorial of full_adder is

begin

    o_S <= i_X xor i_Y xor i_Cin;
    o_Cout <= (i_X and i_Y) or (i_Cin and (i_X xor i_Y));

end behavorial;