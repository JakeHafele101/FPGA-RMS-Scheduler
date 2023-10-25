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

architecture structural of full_adder is

    --2 input XOR gate (output 1 if only one input is 1)
    component xorg2 is
        port (
            i_A : in std_logic;
            i_B : in std_logic;
            o_F : out std_logic);
    end component;

    --2 input and gate
    component andg2 is
        port (
            i_A : in std_logic;
            i_B : in std_logic;
            o_F : out std_logic);
    end component;

    --2 input or gate
    component org2 is
        port (
            i_A : in std_logic;
            i_B : in std_logic;
            o_F : out std_logic);
    end component;

    --intermediate signal declaration would go here!
    signal s_XOR1, s_AND1, s_AND2 : std_logic;

begin

    --i_X XOR i_Y
    g_xorg2_1 : xorg2
    port map(
        i_A => i_X,
        i_B => i_Y,
        o_F => s_XOR1);

    --s_XOR_X_Y XOR i_Cin for output o_S
    g_xorg2_2 : xorg2
    port map(
        i_A => i_Cin,
        i_B => s_XOR1,
        o_F => o_S);

    --s_XOR_X_Y AND i_Cin
    g_and2_1 : andg2
    port map(
        i_A => i_Cin,
        i_B => s_XOR1,
        o_F => s_AND1);

    --i_X AND i_Y
    g_and2_2 : andg2
    port map(
        i_A => i_X,
        i_B => i_Y,
        o_F => s_AND2);

    g_or2_1 : org2
    port map(
        i_A => s_AND1,
        i_B => s_AND2,
        o_F => o_Cout);

end structural;