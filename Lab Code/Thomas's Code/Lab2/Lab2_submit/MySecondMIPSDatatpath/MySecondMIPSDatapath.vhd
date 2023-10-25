LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.array32.ALL;

ENTITY MySecondMIPSDatapath IS
    PORT (
        rs : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        rt : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        rd : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
        immeEn : IN STD_LOGIC;
        imme : IN STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
        writeEn : IN STD_LOGIC;
        memWriteEn : IN STD_LOGIC;
        writeSel : IN STD_LOGIC;
        signZeroSel : IN STD_LOGIC;
        nAddSub : IN STD_LOGIC;
        i_CLK : IN STD_LOGIC;
        i_RST : IN STD_LOGIC;
        o_Carry : OUT STD_LOGIC;
        o_sum : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
        o_q : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
END MySecondMIPSDatapath;

ARCHITECTURE structural OF MySecondMIPSDatapath IS
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

    COMPONENT mem
        GENERIC (
            DATA_WIDTH : NATURAL := 32;
            ADDR_WIDTH : NATURAL := 10
        );
        PORT (
            clk : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
            data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
            we : IN STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
    END COMPONENT;

    COMPONENT extender
        PORT (
            i_in : IN STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
            i_ctl : IN STD_LOGIC;
            o_ext : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
    END COMPONENT;

    SIGNAL s_Sum : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_q : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_rs : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_rt : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Mux : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_ext : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Write : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    o_Sum <= s_Sum;
    o_q <= s_q;
    REGS : RegFile
    PORT MAP(
        rsSel => rs,
        rtSel => rt,
        writeSel => rd,
        write1 => s_write,
        writeEn => writeEn,
        i_CLK => i_CLK,
        i_RST => i_RST,
        rs => s_rs,
        rt => s_rt
    );

    MUXIMME : mux2t1_N GENERIC MAP(N => 32)
    PORT MAP(
        i_S => immeEn,
        i_D0 => s_rt,
        i_D1 => s_Ext,
        o_O => s_Mux
    );

    MUXWRITE : mux2t1_N GENERIC MAP(N => 32)
    PORT MAP(
        i_S => writeSel,
        i_D0 => s_Sum,
        i_D1 => s_q,
        o_O => s_write
    );

    ADDSUB : NAdd_Sub GENERIC MAP(N => 32)
    PORT MAP(
        A => s_rs,
        B => s_Mux,
        nAdd_Sub => nAddSub,
        o_Sum => s_Sum,
        o_Carry => o_Carry
    );

    BITEXT : extender
    PORT MAP(
        i_in => imme,
        i_ctl => signZeroSel,
        o_ext => s_ext
    );

    dmem : mem GENERIC MAP(
        DATA_WIDTH => 32,
        ADDR_WIDTH => 10)
    PORT MAP(
        clk => i_clk,
        addr => s_sum(9 DOWNTO 0),
        data => s_rt,
        we => memWriteEn,
        q => s_q
    );
END structural;