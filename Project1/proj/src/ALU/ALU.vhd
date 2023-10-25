-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a ALU with shift, logic, add subtract, and branching
-- for a simple single cycle processor
--
-- 
-- Created 1/24/2023
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ALU IS
    PORT (
        i_nAdd_Sub : IN STD_LOGIC;
        i_shift_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_branch_Sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_logic_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_out_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_rt : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_branch : OUT STD_LOGIC;
        o_overflow : OUT STD_LOGIC;
        o_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END ALU;

ARCHITECTURE mixed OF ALU IS

    COMPONENT adder_subber IS
        GENERIC (N : INTEGER := 32); --default 32 bit input
        PORT (
            i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_nAdd_Sub : IN STD_LOGIC;
            o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_overflow : OUT STD_LOGIC;
            o_Cout : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT logic IS
        PORT (
            i_logic_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_rt : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT shift IS
        PORT (
            i_shift_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            i_rt : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT branch IS
        PORT (
            i_branch_Sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_rt :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_branch : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT ripple_adder IS
        GENERIC (N : INTEGER := 32); --default 32 bit input
        PORT (
            i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Cin : IN STD_LOGIC;
            o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_overflow : OUT STD_LOGIC;
            o_Cout : OUT STD_LOGIC);
    END COMPONENT;

    -- Internal signals
    SIGNAL s_zero : STD_LOGIC;
    SIGNAL s_sum : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_shift : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_logic : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_setLessThan : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_lessThan : STD_LOGIC;
    SIGNAL s_carry : STD_LOGIC;
    SIGNAL s_rt31_inv : STD_LOGIC;
BEGIN
    s_zero <= '1' WHEN s_sum = X"00000000" ELSE
        '0';

    g_add_sub : adder_subber
    GENERIC MAP(N => 32)
    PORT MAP(
        i_A => i_rs,
        i_B => i_rt,
        i_nAdd_Sub => i_nAdd_Sub,
        o_S => s_sum,
        o_Cout => s_carry,
        o_overflow => o_overflow);

    g_logic : logic
    PORT MAP(
        i_logic_Sel => i_logic_Sel,
        i_rs => i_rs,
        i_rt => i_rt,
        o_result => s_logic);

    g_shift : shift
    PORT MAP(
        i_shift_Sel => i_shift_Sel,
        i_rt => i_rt,
        i_shamt => i_shamt,
        o_result => s_shift);

    g_branch : branch
    PORT MAP(
        i_branch_Sel => i_branch_Sel,
        i_rs => i_rs,
        i_rt =>i_rt, 
        o_branch => o_branch);

    s_rt31_inv <= NOT i_rt(31);
        g_ripple_sll : ripple_adder
        GENERIC MAP(N => 1)
        PORT MAP(
            i_X(0) => i_rs(31),
            i_Y(0) => s_rt31_inv,
            i_Cin => s_carry,
            o_S(0) => s_lessThan);
    s_setLessThan <= "0000000000000000000000000000000" & s_lessThan;

    WITH i_out_Sel SELECT
        o_rd <= s_sum WHEN "00",
        s_shift WHEN "01",
        s_logic WHEN "10",
        s_setLessThan WHEN OTHERS;

END mixed;