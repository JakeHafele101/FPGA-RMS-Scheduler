LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_MyFirstMIPSDatapath IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_MyFirstMIPSDatapath;

ARCHITECTURE behavior OF tb_MyFirstMIPSDatapath IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT MyFirstMIPSDatapath
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
    END COMPONENT;

    SIGNAL s_rs : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_rt : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_rd : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_immeEn : STD_LOGIC := '0';
    SIGNAL s_imme : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := x"00000000";
    SIGNAL s_writeEn : STD_LOGIC := '0';
    SIGNAL s_nAddSub : STD_LOGIC := '0';
    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_RST : STD_LOGIC := '1';
    SIGNAL s_Carry : STD_LOGIC;
    SIGNAL s_sum : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    DUT : MyFirstMIPSDatapath
    PORT MAP(
        rs => s_rs,
        rt => s_rt,
        rd => s_rd,
        immeEn => s_immeEn,
        imme => s_imme,
        writeEn => s_writeEn,
        nAddSub => s_nAddSub,
        i_CLK => s_CLK,
        i_RST => s_RST,
        o_Carry => s_Carry,
        o_sum => s_sum);

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
        WAIT FOR cCLK_PER/4;
        s_RST <= '0';
        WAIT FOR cCLK_PER;
        -- $1 = 1
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(1, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $2 = 2
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(2, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $3 = 3
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(3, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(3, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $4 = 4
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(4, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(4, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $5 = 5
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(5, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(5, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $6 = 6
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(6, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(6, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $7 = 7
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(7, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(7, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $8 = 8
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(8, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(8, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $9 = 9
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(9, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(9, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $10 = 10
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(10, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(10, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $11 = 1 + 2
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(1, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(2, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(11, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $12 = 3-3
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '1';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(11, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(3, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(12, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $13 = 0+4
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(12, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(4, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(13, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $14 = 4-5
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '1';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(13, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(5, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(14, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $15 = -1+6
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(14, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(6, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(15, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $16 = 5-7
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '1';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(15, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(7, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(16, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $17 = -2+8
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(16, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(8, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(17, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $18 = 6-9
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '1';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(17, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(9, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(18, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $19 = -3+10
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(18, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(10, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(19, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $20 = -35
        s_immeEn <= '1';
        s_imme <= STD_LOGIC_VECTOR(to_signed(-35, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(0, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(20, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        -- $21 = 7+-35
        s_immeEn <= '0';
        s_imme <= STD_LOGIC_VECTOR(to_unsigned(0, s_imme'length));
        s_nAddSub <= '0';
        s_rs <= STD_LOGIC_VECTOR(to_unsigned(19, s_rs'length));
        s_rt <= STD_LOGIC_VECTOR(to_unsigned(20, s_rs'length));
        s_rd <= STD_LOGIC_VECTOR(to_unsigned(21, s_rs'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
    END PROCESS;

END behavior;