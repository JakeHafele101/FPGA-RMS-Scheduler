LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

USE work.array32.ALL;

ENTITY tb_RegFile IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_RegFile;

ARCHITECTURE behavior OF tb_RegFile IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT RegFile
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
    END COMPONENT;

    SIGNAL s_rsSel : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_rtSel : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_writeSel : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0) := "00000";
    SIGNAL s_write1 : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := x"00000000";
    SIGNAL s_writeEn : STD_LOGIC := '0';
    SIGNAL s_CLK : STD_LOGIC :='0';
    SIGNAL s_rs : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_rt : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_RST : STD_LOGIC:= '1';

BEGIN
    DUT : RegFile
    PORT MAP(
        rsSel => s_rsSel,
        rtSel => s_rtSel,
        writeSel => s_writeSel,
        write1 => s_write1,
        writeEn => s_writeEn,
        i_CLK => s_CLK,
        rs => s_rs,
        rt => s_rt,
        i_RST => s_RST);

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
        WAIT FOR cCLK_PER;
        s_RST <= '0';
        s_rsSel <= "00000";
        s_rtSel <= "00000";
        s_writeSel <=  "00000";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(0, s_write1'length));
        s_writeEn <= '0';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00000";
        s_rtSel <= "00001";
        s_writeSel <=  "00001";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(5, s_write1'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00000";
        s_rtSel <= "00001";
        s_writeSel <=  "00001";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(5, s_write1'length));
        s_writeEn <= '0';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00000";
        s_rtSel <= "00001";
        s_writeSel <=  "00001";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(8, s_write1'length));
        s_writeEn <= '0';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00000";
        s_rtSel <= "00001";
        s_writeSel <=  "00000";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(37, s_write1'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00001";
        s_rtSel <= "10110";
        s_writeSel <= "10110";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(456411, s_write1'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
        s_rsSel <= "00001";
        s_rtSel <= "10110";
        s_writeSel <= "10110";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(41, s_write1'length));
        s_writeEn <= '0';
        WAIT FOR cCLK_PER;
        s_rsSel <= "10110";
        s_rtSel <= "10110";
        s_writeSel <= "10110";
        s_write1 <= STD_LOGIC_VECTOR(to_unsigned(41, s_write1'length));
        s_writeEn <= '1';
        WAIT FOR cCLK_PER;
    END PROCESS;

END behavior;