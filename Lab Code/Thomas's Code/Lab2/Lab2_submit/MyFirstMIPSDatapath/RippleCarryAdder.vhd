LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY RippleCarryAdder IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
        i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        i_Carry : IN STD_LOGIC;
        o_Carry : OUT STD_LOGIC;
        o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END RippleCarryAdder;

ARCHITECTURE structural OF RippleCarryAdder IS

    COMPONENT FullAdder IS
        PORT (
            i_D0 : IN STD_LOGIC;
            i_D1 : IN STD_LOGIC;
            i_Carry : IN STD_LOGIC;
            o_Sum : OUT STD_LOGIC;
            o_Carry : OUT STD_LOGIC);
    END COMPONENT;
    SIGNAL s_Carry : STD_LOGIC_VECTOR(N DOWNTO 0);
BEGIN
    s_Carry(0) <= i_Carry;
    o_Carry <= s_Carry(N-1);
    G_RippleAdder : FOR i IN 0 TO N - 1 GENERATE
        FADD : FullAdder PORT MAP(
            i_D0(i), i_D1(i), s_Carry(i), o_Sum(i), s_Carry(i + 1)
        );
    END GENERATE G_RippleAdder;
END structural;