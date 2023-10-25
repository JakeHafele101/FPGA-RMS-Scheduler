LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.array32.ALL;

ENTITY MyFirstMIPSDatapath IS
    GENERIC (N : INTEGER := 32);
    PORT (
        rs : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        rt : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        rd : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        immeEn : IN STD_LOGIC;
        imme : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        writeEn : IN STD_LOGIC;
        nAddSub : IN STD_LOGIC;
        i_CLK : IN STD_LOGIC;
        i_RST : IN STD_LOGIC;
        o_Carry : OUT STD_LOGIC;
        o_sum : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
END MyFirstMIPSDatapath;

ARCHITECTURE structural OF MyFirstMIPSDatapath IS
    COMPONENT RegFile IS
        PORT (
            rsSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
            rtSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
            writeSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
            write1 : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
            writeEn : IN STD_LOGIC;
            i_CLK : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            rs : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
            rt : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0)
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

    COMPONENT NAdd_Sub IS
        GENERIC (N : INTEGER := 32);
        PORT (
            A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            nAdd_Sub : IN STD_LOGIC;
            o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Carry : OUT STD_LOGIC);
    END COMPONENT;
    SIGNAL s_Sum : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_rs : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_rt : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Mux : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    o_Sum <= s_Sum;
    REGS : RegFile
    PORT MAP(
        rsSel => rs,
        rtSel => rt,
        writeSel => rd,
        write1 => s_Sum,
        writeEn => writeEn,
        i_CLK => i_CLK,
        i_RST => i_RST,
        rs => s_rs,
        rt => s_rt
    );

    MUX : mux2t1_N GENERIC MAP(N => N)
    PORT MAP(
        i_S => immeEn,
        i_D0 => s_rt,
        i_D1 => imme,
        o_O => s_Mux
    );

    ADDSUB : NAdd_Sub GENERIC MAP(N => N)
    PORT MAP(
        A => s_rs,
        B => s_Mux,
        nAdd_Sub => nAddSub,
        o_Sum => s_Sum,
        o_Carry => o_Carry
    );
END structural;