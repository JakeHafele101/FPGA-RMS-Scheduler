-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Branchvhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the logic part of an ALU for branching
--
-- 
-- Created 1/24/2023
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY branch IS
    PORT (
        i_branch_Sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_rt :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_branch : OUT  STD_LOGIC);
END branch;

ARCHITECTURE structural OF branch IS

    -- Internal signals
    SIGNAL s_XOR : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_bgez, s_bgezal, s_bgtz, s_blez, s_bltzal, s_bltz, s_beq, s_bne : STD_LOGIC;
    SIGNAL s_zeroRS, s_negative, s_nonNegative, s_nonZeroRS, s_equal: STD_LOGIC;

BEGIN
    s_XOR <= i_rs XOR i_rt;
    s_equal <= '1' when s_XOR = X"00000000" ELSE '0';
    s_negative <= i_rs(31);
    s_nonNegative <= not i_rs(31);
    s_zeroRS <= '1' WHEN i_rs = X"00000000" ELSE '0';
    s_nonZeroRS <= not s_zeroRS;

    s_beq <= s_equal;     -- branch if equal
    s_bne <= not s_equal; -- branch if not equal
    s_bgez <= s_nonNegative or s_zeroRS;   --branch if greater than OR equal to 0. rt = 00001
    s_bgezal <= s_nonNegative or s_zeroRS;  --branch if greater than  0 AND link. rt = 10001
    s_bgtz <= s_nonZeroRS and s_nonNegative;     --branch if greater than 0. rt = 00000
    s_blez <= s_zeroRS or s_negative;     --Branch if less than OR equal to zero. rt = 00000
    s_bltzal <= s_negative;    --branch if less than 0 AND link. rt = 10000
    s_bltz <= s_negative;     --branch if less than 0. rt = 00000

    WITH i_branch_Sel SELECT
        o_branch <= s_beq WHEN "000",
        s_bne WHEN "001",
        s_bgez WHEN "010",
        s_bgezal WHEN "011",
        s_bgtz WHEN "100",
        s_blez WHEN "101",
        s_bltzal WHEN "110",
        s_bltz WHEN "111",
        '0' WHEN OTHERS;

END structural;