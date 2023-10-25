-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder_subber.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- ripple carry adder using structural VHDL, generics, and generate 
-- statements.
--
-- 
-- Created 1/23/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_subber is
    generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port (
        i_A        : in std_logic_vector(N - 1 downto 0);
        i_B        : in std_logic_vector(N - 1 downto 0);
        i_nAdd_Sub : in std_logic;
        o_S        : out std_logic_vector(N - 1 downto 0);
        o_overflow : out std_logic;
        o_Cout     : out std_logic);
end adder_subber;

architecture structural of adder_subber is

    component ones_comp is
        generic (N : integer := 32); --default 32 bit input
        port (
            i_A : in std_logic_vector ((N - 1) downto 0);   --input to be inverted
            o_F : out std_logic_vector ((N - 1) downto 0)); --inverted output
    end component;

    component mux2t1_N is
        generic (N : integer := 16); -- Generic of type integer for input/output data width. Default value is 16.
        port (
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(N - 1 downto 0);
            i_D1 : in std_logic_vector(N - 1 downto 0);
            o_O  : out std_logic_vector(N - 1 downto 0));
    end component;

    component ripple_adder is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_X    : in std_logic_vector(N - 1 downto 0);
            i_Y    : in std_logic_vector(N - 1 downto 0);
            i_Cin  : in std_logic;
            o_S    : out std_logic_vector(N - 1 downto 0);
            o_overflow : out std_logic;
            o_Cout : out std_logic);
    end component;

    -- Internal signals
    signal s_not_B, s_add_B : std_logic_vector(N - 1 downto 0);

begin

    g_ones_comp : ones_comp
    generic map(N => N)
    port map(
        i_A => i_B,
        o_F => s_not_B);

    g_mux2t1_N : mux2t1_N
    generic map(N => N)
    port map(
        i_S  => i_nAdd_Sub,
        i_D0 => i_B,
        i_D1 => s_not_B,
        o_O  => s_add_B);

    g_ripple_adder : ripple_adder
    generic map(N => N)
    port map(
        i_X    => i_A,
        i_Y    => s_add_B,
        i_Cin  => i_nAdd_Sub,
        o_S    => o_S,
        o_overflow => o_overflow,
        o_Cout => o_Cout);

end structural;