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

library IEEE;
use IEEE.std_logic_1164.all;

entity branch is
    port (
        i_branch_Sel : in std_logic_vector(2 downto 0);
        i_rs         : in std_logic_vector(31 downto 0);
        i_rt         : in std_logic_vector(31 downto 0);
        o_branch     : out std_logic);
end branch;

architecture structural of branch is

    -- Internal signals
    signal s_XOR : std_logic_vector(31 downto 0);
    signal s_bgez, s_bgezal, s_bgtz, s_blez, s_bltzal, s_bltz, s_beq, s_bne : std_logic;
    signal s_zeroRS, s_negative, s_nonNegative, s_nonZeroRS, s_equal : std_logic;

begin
    s_XOR <= i_rs xor i_rt;
    s_equal <= '1' when s_XOR = X"00000000" else
        '0';
    s_negative <= i_rs(31);
    s_nonNegative <= not i_rs(31);
    s_zeroRS <= '1' when i_rs = X"00000000" else
        '0';
    s_nonZeroRS <= not s_zeroRS;

    s_beq <= s_equal; -- branch if equal
    s_bne <= not s_equal; -- branch if not equal
    s_bgez <= s_nonNegative or s_zeroRS; --branch if greater than OR equal to 0. rt = 00001
    s_bgezal <= s_nonNegative or s_zeroRS; --branch if greater than  0 AND link. rt = 10001
    s_bgtz <= s_nonZeroRS and s_nonNegative; --branch if greater than 0. rt = 00000
    s_blez <= s_zeroRS or s_negative; --Branch if less than OR equal to zero. rt = 00000
    s_bltzal <= s_negative; --branch if less than 0 AND link. rt = 10000
    s_bltz <= s_negative; --branch if less than 0. rt = 00000

    with i_branch_Sel select
        o_branch <= s_beq when "000",
        s_bne when "001",
        s_bgez when "010",
        s_bgezal when "011",
        s_bgtz when "100",
        s_blez when "101",
        s_bltzal when "110",
        s_bltz when "111",
        '0' when others;

end structural;