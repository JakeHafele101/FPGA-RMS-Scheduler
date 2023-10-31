-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ripple_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- ripple carry adder using structural VHDL, generics, and generate 
-- statements.
--
-- 
-- Created 1/22/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ripple_adder is
    generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port (
        i_X    : in std_logic_vector(N - 1 downto 0);
        i_Y    : in std_logic_vector(N - 1 downto 0);
        i_Cin  : in std_logic;
        o_S    : out std_logic_vector(N - 1 downto 0);
        o_Cout : out std_logic);
end ripple_adder;

architecture structural of ripple_adder is

    component full_adder is
        port (
            i_X    : in std_logic;
            i_Y    : in std_logic;
            i_Cin  : in std_logic;
            o_S    : out std_logic;
            o_Cout : out std_logic);
    end component;

    -- Internal signals
    signal s_C : std_logic_vector(N downto 0);
begin

    -- Instantiate N full_adder components
    G_NBit_ADDER : for i in 0 to N - 1 generate
        ADDERI : full_adder
        port map(
            i_X    => i_X(i),
            i_Y    => i_Y(i),
            i_Cin  => s_C(i),
            o_S    => o_S(i),
            o_Cout => s_C(i + 1));
    end generate G_NBit_ADDER;

    -- internal signal assignments
    s_C(0) <= i_Cin;

    -- Output assignments
    o_Cout <= s_C(N); --MSB of s_C assigned as carry out bit (is bit N and not N-1 since N-1 adders)

end structural;