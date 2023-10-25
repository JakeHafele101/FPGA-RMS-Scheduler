LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_MySecondMIPSDatapath IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_MySecondMIPSDatapath;

ARCHITECTURE behavior OF tb_MySecondMIPSDatapath IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT MySecondMIPSDatapath
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
    END COMPONENT;

    SIGNAL s_rs : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_rt : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_rd : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_immeEn : STD_LOGIC := '0';
    SIGNAL s_imme : STD_LOGIC_VECTOR(16 - 1 DOWNTO 0) := x"0000";
    SIGNAL s_writeEn : STD_LOGIC := '0';
    SIGNAL s_memWriteEn : STD_LOGIC := '0';
    SIGNAL s_writeSel : STD_LOGIC := '0';
    SIGNAL s_signZeroSel : STD_LOGIC := '1';
    SIGNAL s_nAddSub : STD_LOGIC := '0';
    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_RST : STD_LOGIC := '1';
    SIGNAL s_Carry : STD_LOGIC;
    SIGNAL s_sum : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_q : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    DUT : MySecondMIPSDatapath
    PORT MAP(
        rs => s_rs,
        rt => s_rt,
        rd => s_rd,
        immeEn => s_immeEn,
        imme => s_imme,
        writeEn => s_writeEn,
        memWriteEn => s_memWriteEn,
        writeSel => s_writeSel,
        SignZeroSel => s_signZeroSel,
        nAddSub => s_nAddSub,
        i_CLK => s_CLK,
        i_RST => s_RST,
        o_Carry => s_Carry,
        o_sum => s_sum,
        o_q => s_q);

    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    -- Testbench process  
    P_TB : PROCESS
    BEGIN
        s_RST <= '0';
        -- addi $25, $0, 0
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- addi $26, $0, 256
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(64, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $1, 0($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 4($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(1, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, 0($26)  THROUGH HERE
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 8($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(2, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        s_memWriteEn <= '0';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, 4($26)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(1, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 12($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(3, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        s_memWriteEn <= '0';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, 8($26)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(2, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 16($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(4, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        s_memWriteEn <= '0';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, 12($26)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(3, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 20($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(5, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        s_memWriteEn <= '0';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, 16($26)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(4, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(26, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
        -- lw $2, 24($25)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(6, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(25, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeSel <= '1';
        s_writeEn <= '1';
        s_memWriteEn <= '0';
        WAIT FOR cCLK_PER;
        -- add $1, $1, $2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- addi $27, $0, 512
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(128, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(27, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- sw $1, -4($27)
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_signed(-1, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(27, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_writeSel <= '0';
        s_writeEn <= '0';
        s_memWriteEn <= '1';
        WAIT FOR cCLK_PER;
    END PROCESS;
END behavior;