-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ones_comp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N bit ones 
-- complement circuit that inverts each individual bit
--
-- 
-- Created 1/19/2023 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
entity ones_comp is
    generic (N : integer := 32); --default 32 bit input
    port (
        i_A : in std_logic_vector ((N - 1) downto 0);   --input to be inverted
        o_F : out std_logic_vector ((N - 1) downto 0)); --inverted output

end ones_comp;

architecture structural of ones_comp is

    -- not gate component description
    component invg is
        port (
            i_A : in std_logic;
            o_F : out std_logic);
    end component;

begin

    -- Instantiate N NOT instances.
    G_NBit_ones_comp : for i in 0 to N - 1 generate
        INVI : invg
        port map(
            i_A => i_A(i),  -- ith bit of input i_A
            o_F => o_F(i)); -- ith bit of output o_F
    end generate G_NBit_ones_comp;

end structural;