LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.array32.ALL;

ENTITY RegFile IS
    GENERIC (N : INTEGER := 32);
    PORT (
        rsSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        rtSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        writeSel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        write1 : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        writeEn : IN STD_LOGIC;
        i_CLK : IN STD_LOGIC;
        i_RST : IN STD_LOGIC;
        rs : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        rt : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
END RegFile;

ARCHITECTURE structural OF RegFile IS
    COMPONENT decoder IS
        PORT (
            i_Sel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
            i_write : IN STD_LOGIC;
            o_O : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Mux32t1 IS
        PORT (
            i_d : IN array32bits32;
            i_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT NBit_Reg IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_CLK : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            i_WE : IN STD_LOGIC;
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT;
    SIGNAL s_WE : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_output : array32bits32;
BEGIN
    REG : NBit_Reg GENERIC MAP(N => N)
    PORT MAP(
        i_CLK => i_CLK,
        i_WE => s_WE(0),
        i_D => write1,
        o_Q => s_output(0),
        i_RST => '1'
    );
    N_REGS : FOR i IN 1 TO 32 - 1 GENERATE
        REG : NBit_Reg GENERIC MAP(N => N)
        PORT MAP(
            i_CLK => i_CLK,
            i_WE => s_WE(i),
            i_D => write1,
            o_Q => s_output(i),
            i_RST => i_RST
        );
    END GENERATE N_REGS;

    MUX1 : Mux32t1
    PORT MAP(
        i_d => s_output,
        i_sel => rsSel,
        o_out => rs
    );

    MUX2 : Mux32t1
    PORT MAP(
        i_d => s_output,
        i_sel => rtSel,
        o_out => rt);

    DEC : decoder
    PORT MAP(
        i_Sel => writeSel,
        i_write => writeEn,
        o_O => s_WE);

END structural;