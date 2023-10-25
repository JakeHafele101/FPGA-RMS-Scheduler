-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Logic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the logic part of an ALU for or and nor and xor
--
-- 
-- Created 1/24/2023
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY logic IS
    PORT (
        i_logic_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_rt : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_result :out STD_LOGIC_VECTOR(31 DOWNTO 0));
END logic;

ARCHITECTURE structural OF logic IS

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 16.
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    -- Internal signals
    SIGNAL s_andNor, s_xorOr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_and, s_nor, s_xor, s_or : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    s_and <= i_rs and i_rt;
    s_nor <= i_rs nor i_rt;
    s_xor <= i_rs xor i_rt;
    s_or <= i_rs or i_rt;

    g_andNor_mux2t1_N : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_logic_Sel(0),
        i_D0 => s_and,
        i_D1 => s_nor,
        o_O => s_andNor);

    g_xorOr_mux2t1_N : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_logic_Sel(0),
        i_D0 => s_xor,
        i_D1 => s_or,
        o_O => s_xorOr);

    g_total_mux2t1_N : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_logic_Sel(1),
        i_D0 => s_andNor,
        i_D1 => s_xorOr,
        o_O => o_result);
END structural;