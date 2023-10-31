LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

ENTITY tb_TaskControl IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_TaskControl;

ARCHITECTURE behavior OF tb_TaskControl IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT TaskControl
        GENERIC (
            TASK0PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000002";
            TASK1PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000004";
            TASK2PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000008";
            TASK3PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000010";
            TASK4PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000020");
        PORT (
            i_CLK : IN STD_LOGIC;
            i_Asynch_RST : IN STD_LOGIC;
            i_LCM_Clear : IN STD_LOGIC;
            i_Task0_Complete : IN STD_LOGIC;
            i_Task1_Complete : IN STD_LOGIC;
            i_Task2_Complete : IN STD_LOGIC;
            i_Task3_Complete : IN STD_LOGIC;
            i_Task4_Complete : IN STD_LOGIC;
            i_Current_Time : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
            o_Current_Task_Sel : OUT STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
            o_Task0_Period_Clear : OUT STD_LOGIC;
            o_Task1_Period_Clear : OUT STD_LOGIC;
            o_Task2_Period_Clear : OUT STD_LOGIC;
            o_Task3_Period_Clear : OUT STD_LOGIC;
            o_Task4_Period_Clear : OUT STD_LOGIC;
            o_Current_Task_Sel_WE : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL s_CLK : STD_LOGIC;
    SIGNAL s_Asynch_RST : STD_LOGIC;
    SIGNAL s_LCM_Clear : STD_LOGIC;
    SIGNAL s_Task0_Complete : STD_LOGIC;
    SIGNAL s_Task1_Complete : STD_LOGIC;
    SIGNAL s_Task2_Complete : STD_LOGIC;
    SIGNAL s_Task3_Complete : STD_LOGIC;
    SIGNAL s_Task4_Complete : STD_LOGIC;
    SIGNAL s_Current_Time : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Current_Task_Sel : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL s_Task0_Period_Clear : STD_LOGIC;
    SIGNAL s_Task1_Period_Clear : STD_LOGIC;
    SIGNAL s_Task2_Period_Clear : STD_LOGIC;
    SIGNAL s_Task3_Period_Clear : STD_LOGIC;
    SIGNAL s_Task4_Period_Clear : STD_LOGIC;
    SIGNAL s_Current_Task_Sel_WE : STD_LOGIC;
BEGIN
    DUT0 : TaskControl
    PORT MAP(
        i_CLK => s_CLK,
        i_Asynch_RST => s_Asynch_RST,
        i_LCM_Clear => s_LCM_Clear,
        i_Task0_Complete => s_Task0_Complete,
        i_Task1_Complete => s_Task1_Complete,
        i_Task2_Complete => s_Task2_Complete,
        i_Task3_Complete => s_Task3_Complete,
        i_Task4_Complete => s_Task4_Complete,
        i_Current_Time => s_Current_Time,
        o_Current_Task_Sel => s_Current_Task_Sel,
        o_Task0_Period_Clear => s_Task0_Period_Clear,
        o_Task1_Period_Clear => s_Task1_Period_Clear,
        o_Task2_Period_Clear => s_Task2_Period_Clear,
        o_Task3_Period_Clear => s_Task3_Period_Clear,
        o_Task4_Period_Clear => s_Task4_Period_Clear,
        o_Current_Task_Sel_WE => s_Current_Task_Sel_WE);

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
        s_Asynch_RST <= '1';
        s_LCM_Clear <= '0';
        s_Task0_Complete <= '0';
        s_Task1_Complete <= '0';
        s_Task2_Complete <= '0';
        s_Task3_Complete <= '0';
        s_Task4_Complete <= '0';
        s_Current_Time <=STD_LOGIC_VECTOR(to_unsigned(1, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Asynch_RST <= '0';
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(1, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(2, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(3, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(4, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(5, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(6, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(7, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(8, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(9, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(10, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(11, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(12, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(13, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(14, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(15, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(16, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(17, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(18, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_Current_Time <= STD_LOGIC_VECTOR(to_unsigned(19, s_Current_Time'length));
        WAIT FOR cCLK_PER;
        s_LCM_Clear <= '1';
        WAIT FOR cCLK_PER;
        s_LCM_Clear <= '0';
        WAIT FOR cCLK_PER;
        s_Task0_Complete <= '1';
        WAIT FOR cCLK_PER;
        s_Task1_Complete <= '1';
        WAIT FOR cCLK_PER;
        s_Task2_Complete <= '1';
        WAIT FOR cCLK_PER;
        s_Task3_Complete <= '1';
        WAIT FOR cCLK_PER;
        s_Task4_Complete <= '1';
        WAIT FOR cCLK_PER;
        s_Task3_Complete <= '0';
        WAIT FOR cCLK_PER;
        s_Task2_Complete <= '0';
        WAIT FOR cCLK_PER;
        s_Task1_Complete <= '0';
        s_Task2_Complete <= '1';
        WAIT FOR cCLK_PER;
    END PROCESS;

END behavior;