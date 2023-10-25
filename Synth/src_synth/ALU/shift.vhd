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

ENTITY shift IS
    PORT (
        i_shift_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_rt : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END shift;

ARCHITECTURE structural OF shift IS
    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 16.
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT;

    -- Internal signals
    SIGNAL s_l1, s_l2, s_l4, s_l8, s_l16 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_r1, s_r2, s_r4, s_r8, s_r16 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_rn1, s_rn2, s_rn4, s_rn8, s_rn16, s_right : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_shift : STD_LOGIC_VECTOR(4 DOWNTO 0);

    SIGNAL s_l1a, s_l2a, s_l4a, s_l8a, s_l16a : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_r1a, s_r2a, s_r4a, s_r8a, s_r16a : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_rn1a, s_rn2a, s_rn4a, s_rn8a, s_rn16a : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_rightCTL : STD_LOGIC;

BEGIN
    -- Checks to see if left shift is done to the shampt or sift 16 for load upper immediate
    shampt : mux2t1_N
    GENERIC MAP(N => 5)
    PORT MAP(
        i_S => i_shift_Sel(1),
        i_D0 => i_shamt,
        i_D1 => "10000",
        o_O => s_shift);
    -- Shifts to the left 1,2,4,8,16 take from the shamt
    s_l1a <= i_rt(30 DOWNTO 0) & "0";
    lshift1 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_shift(0),
        i_D0 => i_rt,
        i_D1 => s_l1a,
        o_O => s_l1);

    s_l2a <= s_l1(29 DOWNTO 0) & "00";
    lshift2 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_shift(1),
        i_D0 => s_l1,
        i_D1 => s_l2a,
        o_O => s_l2);

    s_l4a <= s_l2(27 DOWNTO 0) & "0000";
    lshift4 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_shift(2),
        i_D0 => s_l2,
        i_D1 => s_l4a,
        o_O => s_l4);

    s_l8a <= s_l4(23 DOWNTO 0) & "00000000";
    lshift8 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_shift(3),
        i_D0 => s_l4,
        i_D1 => s_l8a,
        o_O => s_l8);

    s_l16a <= s_l8(15 DOWNTO 0) & "0000000000000000";
    lshift16 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_shift(4),
        i_D0 => s_l8,
        i_D1 => s_l16a,
        o_O => s_l16);

    -- Shifts to the right 1,2,4,8,16 taken from the shamt adding in 0
    s_r1a <= "0" & i_rt(31 DOWNTO 1);
    rshift1 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(0),
        i_D0 => i_rt,
        i_D1 => s_r1a,
        o_O => s_r1);

    s_r2a <= "00" & s_r1(31 DOWNTO 2);
    rshift2 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(1),
        i_D0 => s_r1,
        i_D1 => s_r2a,
        o_O => s_r2);

    s_r4a <= "0000" & s_r2(31 DOWNTO 4);
    rshift4 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(2),
        i_D0 => s_r2,
        i_D1 => s_r4a,
        o_O => s_r4);

    s_r8a <= "00000000" & s_r4(31 DOWNTO 8);
    rshift8 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(3),
        i_D0 => s_r4,
        i_D1 => s_r8a,
        o_O => s_r8);

    s_r16a <= "0000000000000000" & s_r8(31 DOWNTO 16);
    rshift16 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(4),
        i_D0 => s_r8,
        i_D1 => s_r16a,
        o_O => s_r16);

    -- Shifts to the right 1,2,4,8,16 taken from the shamt adding in 1
    s_rn1a <= "1" & i_rt(31 DOWNTO 1);
    rnshift1 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(0),
        i_D0 => i_rt,
        i_D1 => s_rn1a,
        o_O => s_rn1);

    s_rn2a <= "11" & s_rn1(31 DOWNTO 2);
    rnshift2 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(1),
        i_D0 => s_rn1,
        i_D1 => s_rn2a,
        o_O => s_rn2);

    s_rn4a <= "1111" & s_rn2(31 DOWNTO 4);
    rnshift4 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(2),
        i_D0 => s_rn2,
        i_D1 => s_rn4a,
        o_O => s_rn4);

    s_rn8a <= "11111111" & s_rn4(31 DOWNTO 8);
    rnshift8 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(3),
        i_D0 => s_rn4,
        i_D1 => s_rn8a,
        o_O => s_rn8);

    s_rn16a <= "1111111111111111" & s_rn8(31 DOWNTO 16);
    rnshift16 : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shamt(4),
        i_D0 => s_rn8,
        i_D1 => s_rn16a,
        o_O => s_rn16);

    --At this point all possible input has been gernerated leaving output selection
    -- selects if the right side generated is outputed shifted with ones or 0s
    s_rightCTL <= i_shift_Sel(1)AND i_rt(31);
    right01sel : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => s_rightCTL,
        i_D0 => s_r16,
        i_D1 => s_rn16,
        o_O => s_right);

    -- Selects left or right shift for overal output
    rightLeftSel : mux2t1_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_S => i_shift_Sel(0),
        i_D0 => s_l16,
        i_D1 => s_right,
        o_O => o_result);
END structural;