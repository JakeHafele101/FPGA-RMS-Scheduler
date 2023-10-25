LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY NAdd_Sub IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
        A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        nAdd_Sub : IN STD_LOGIC;
        o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        o_Carry : OUT STD_LOGIC);
END NAdd_Sub;

ARCHITECTURE structural OF NAdd_Sub IS

    COMPONENT N_Bit_inverter IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT RippleCarryAdder IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Carry : IN STD_LOGIC;
            o_Carry : OUT STD_LOGIC;
            o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL s_NotB : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL s_MuxB : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
BEGIN

    -- Instantiate N Inverter instances.
        INVERT : N_Bit_inverter GENERIC MAP(N => N)
        PORT MAP(
            i_A => B,
            o_F => s_NotB);

        MUX : mux2t1_N GENERIC MAP(N => N)
        PORT MAP(
            i_D0 => B,
            i_D1 => s_NotB,
            i_S => nAdd_Sub,
            o_O => s_MuxB);

        ADD : RippleCarryAdder GENERIC MAP(N => N)
        PORT MAP(
             i_D0 =>A,
             i_D1 => s_MuxB,
            i_Carry => nAdd_Sub,
            o_Sum => o_Sum,
            o_Carry => o_Carry);

END structural;