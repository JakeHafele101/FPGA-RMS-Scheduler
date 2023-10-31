-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- TaskControl.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a task control
-- for a RMS hardware Scheduler
--
-- 
-- Created 10/30/2023
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY TaskControl IS
    GENERIC (
        TASK0PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000001";
        TASK1PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000002";
        TASK2PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000004";
        TASK3PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000008";
        TASK4PERIOD : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := X"00000010");
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
END TaskControl;

ARCHITECTURE mixed OF TaskControl IS
    COMPONENT ripple_adder IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Cin : IN STD_LOGIC;
            o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Cout : OUT STD_LOGIC);
    END COMPONENT;

    -- Internal signals
    SIGNAL s_current_PC : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task0_Deadline : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task1_Deadline : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task2_Deadline : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task3_Deadline : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task4_Deadline : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task0_AddOut : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task1_AddOut : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task2_AddOut : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task3_AddOut : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Task4_AddOut : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    g_task0_adder : ripple_adder
    PORT MAP(
        i_X => TASK0PERIOD,
        i_Y => s_Task0_Deadline,
        i_Cin => '0',
        o_S => s_Task0_AddOut,
        o_Cout => OPEN);

    g_task1_adder : ripple_adder
    PORT MAP(
        i_X => TASK1PERIOD,
        i_Y => s_Task1_Deadline,
        i_Cin => '0',
        o_S => s_Task1_AddOut,
        o_Cout => OPEN);

    g_task2_adder : ripple_adder
    PORT MAP(
        i_X => TASK2PERIOD,
        i_Y => s_Task2_Deadline,
        i_Cin => '0',
        o_S => s_Task2_AddOut,
        o_Cout => OPEN);

    g_task3_adder : ripple_adder
    PORT MAP(
        i_X => TASK3PERIOD,
        i_Y => s_Task3_Deadline,
        i_Cin => '0',
        o_S => s_Task3_AddOut,
        o_Cout => OPEN);

    g_task4_adder : ripple_adder
    PORT MAP(
        i_X => TASK4PERIOD,
        i_Y => s_Task4_Deadline,
        i_Cin => '0',
        o_S => s_Task4_AddOut,
        o_Cout => OPEN);

    PROCESS (i_CLK, i_Asynch_RST)
    BEGIN
        IF (i_Asynch_RST = '1') THEN
            s_Task0_Deadline <= TASK0PERIOD;
            s_Task1_Deadline <= TASK1PERIOD;
            s_Task2_Deadline <= TASK2PERIOD;
            s_Task3_Deadline <= TASK3PERIOD;
            s_Task4_Deadline <= TASK4PERIOD;
        elsIF(rising_edge(i_CLK)) THEN
            IF (i_LCM_Clear = '1') THEN
                s_Task0_Deadline <= TASK0PERIOD;
                s_Task1_Deadline <= TASK1PERIOD;
                s_Task2_Deadline <= TASK2PERIOD;
                s_Task3_Deadline <= TASK3PERIOD;
                s_Task4_Deadline <= TASK4PERIOD;
            ELSE
                IF (i_Current_Time > s_Task0_Deadline) THEN
                    o_Task0_Period_Clear <= '1';
                    s_Task0_Deadline <= s_Task0_AddOut;
                ELSE
                    o_Task0_Period_Clear <= '0';
                END IF;
                IF (i_Current_Time > s_Task1_Deadline) THEN
                    o_Task1_Period_Clear <= '1';
                    s_Task1_Deadline <= s_Task1_AddOut;
                ELSE
                    o_Task1_Period_Clear <= '0';
                END IF;
                IF (i_Current_Time > s_Task2_Deadline) THEN
                    o_Task2_Period_Clear <= '1';
                    s_Task2_Deadline <= s_Task2_AddOut;
                ELSE
                    o_Task2_Period_Clear <= '0';
                END IF;
                IF (i_Current_Time > s_Task3_Deadline) THEN
                    o_Task3_Period_Clear <= '1';
                    s_Task3_Deadline <= s_Task3_AddOut;
                ELSE
                    o_Task3_Period_Clear <= '0';
                END IF;
                IF (i_Current_Time > s_Task4_Deadline) THEN
                    o_Task4_Period_Clear <= '1';
                    s_Task4_Deadline <= s_Task4_AddOut;
                ELSE
                    o_Task4_Period_Clear <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (i_Task0_Complete, i_Task1_Complete, i_Task2_Complete, i_Task3_Complete, i_Task4_Complete)
    BEGIN
        IF (rising_edge(i_CLK)) THEN
            IF (i_Task0_Complete = '0') THEN
                o_Current_Task_Sel <= "000";
                o_Current_Task_Sel_WE <= '1';
            ELSIF (i_Task1_Complete = '0') THEN
                o_Current_Task_Sel <= "001";
                o_Current_Task_Sel_WE <= '1';
            ELSIF (i_Task2_Complete = '0') THEN
                o_Current_Task_Sel <= "010";
                o_Current_Task_Sel_WE <= '1';
            ELSIF (i_Task3_Complete = '0') THEN
                o_Current_Task_Sel <= "011";
                o_Current_Task_Sel_WE <= '1';
            ELSIF (i_Task4_Complete = '0') THEN
                o_Current_Task_Sel <= "100";
                o_Current_Task_Sel_WE <= '1';
            ELSE
                o_Current_Task_Sel <= "111";
                o_Current_Task_Sel_WE <= '0';
            END IF;
        END IF;
    END PROCESS;

END mixed;