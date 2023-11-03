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

library IEEE;
use IEEE.std_logic_1164.all;

entity TaskControl is
    generic (
        TASK0PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000002";
        TASK1PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000004";
        TASK2PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000004";
        TASK3PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000008";
        TASK4PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000010");
    port (
        i_CLK                 : in std_logic;
        i_Asynch_RST          : in std_logic;
        i_LCM_Clear           : in std_logic;
        i_Task0_Complete      : in std_logic;
        i_Task1_Complete      : in std_logic;
        i_Task2_Complete      : in std_logic;
        i_Task3_Complete      : in std_logic;
        i_Task4_Complete      : in std_logic;
        i_Current_Time        : in std_logic_vector(32 - 1 downto 0);
        o_Current_Task_Sel    : out std_logic_vector(3 - 1 downto 0);
        o_Task0_Period_Clear  : out std_logic;
        o_Task1_Period_Clear  : out std_logic;
        o_Task2_Period_Clear  : out std_logic;
        o_Task3_Period_Clear  : out std_logic;
        o_Task4_Period_Clear  : out std_logic;
        o_Current_Task_Sel_WE : out std_logic);
end TaskControl;

architecture mixed of TaskControl is
    component ripple_adder is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_X    : in std_logic_vector(N - 1 downto 0);
            i_Y    : in std_logic_vector(N - 1 downto 0);
            i_Cin  : in std_logic;
            o_S    : out std_logic_vector(N - 1 downto 0);
            o_Cout : out std_logic);
    end component;

    -- Internal signals
    signal s_current_PC     : std_logic_vector(32 - 1 downto 0);
    signal s_Task0_Deadline : std_logic_vector(32 - 1 downto 0);
    signal s_Task1_Deadline : std_logic_vector(32 - 1 downto 0);
    signal s_Task2_Deadline : std_logic_vector(32 - 1 downto 0);
    signal s_Task3_Deadline : std_logic_vector(32 - 1 downto 0);
    signal s_Task4_Deadline : std_logic_vector(32 - 1 downto 0);
    signal s_Task0_AddOut   : std_logic_vector(32 - 1 downto 0);
    signal s_Task1_AddOut   : std_logic_vector(32 - 1 downto 0);
    signal s_Task2_AddOut   : std_logic_vector(32 - 1 downto 0);
    signal s_Task3_AddOut   : std_logic_vector(32 - 1 downto 0);
    signal s_Task4_AddOut   : std_logic_vector(32 - 1 downto 0);

begin
    g_task0_adder : ripple_adder
    port map(
        i_X    => TASK0PERIOD,
        i_Y    => s_Task0_Deadline,
        i_Cin  => '1',
        o_S    => s_Task0_AddOut,
        o_Cout => open);

    g_task1_adder : ripple_adder
    port map(
        i_X    => TASK1PERIOD,
        i_Y    => s_Task1_Deadline,
        i_Cin  => '1',
        o_S    => s_Task1_AddOut,
        o_Cout => open);

    g_task2_adder : ripple_adder
    port map(
        i_X    => TASK2PERIOD,
        i_Y    => s_Task2_Deadline,
        i_Cin  => '1',
        o_S    => s_Task2_AddOut,
        o_Cout => open);

    g_task3_adder : ripple_adder
    port map(
        i_X    => TASK3PERIOD,
        i_Y    => s_Task3_Deadline,
        i_Cin  => '1',
        o_S    => s_Task3_AddOut,
        o_Cout => open);

    g_task4_adder : ripple_adder
    port map(
        i_X    => TASK4PERIOD,
        i_Y    => s_Task4_Deadline,
        i_Cin  => '1',
        o_S    => s_Task4_AddOut,
        o_Cout => open);

    process (i_CLK, i_Asynch_RST)
    begin
        if (i_Asynch_RST = '1') then
            s_Task0_Deadline     <= TASK0PERIOD;
            s_Task1_Deadline     <= TASK1PERIOD;
            s_Task2_Deadline     <= TASK2PERIOD;
            s_Task3_Deadline     <= TASK3PERIOD;
            s_Task4_Deadline     <= TASK4PERIOD;
            o_Task0_Period_Clear <= '1';
            o_Task1_Period_Clear <= '1';
            o_Task2_Period_Clear <= '1';
            o_Task3_Period_Clear <= '1';
            o_Task4_Period_Clear <= '1';
        elsif (rising_edge(i_CLK)) then
            if (i_LCM_Clear = '1') then
                s_Task0_Deadline     <= TASK0PERIOD;
                s_Task1_Deadline     <= TASK1PERIOD;
                s_Task2_Deadline     <= TASK2PERIOD;
                s_Task3_Deadline     <= TASK3PERIOD;
                s_Task4_Deadline     <= TASK4PERIOD;
                o_Task0_Period_Clear <= '1';
                o_Task1_Period_Clear <= '1';
                o_Task2_Period_Clear <= '1';
                o_Task3_Period_Clear <= '1';
                o_Task4_Period_Clear <= '1';
            else
                if (i_Current_Time >= s_Task0_Deadline) then --FIXME????
                    o_Task0_Period_Clear <= '1';
                    s_Task0_Deadline     <= s_Task0_AddOut;
                else
                    o_Task0_Period_Clear <= '0';
                end if;
                if (i_Current_Time >= s_Task1_Deadline) then
                    o_Task1_Period_Clear <= '1';
                    s_Task1_Deadline     <= s_Task1_AddOut;
                else
                    o_Task1_Period_Clear <= '0';
                end if;
                if (i_Current_Time >= s_Task2_Deadline) then
                    o_Task2_Period_Clear <= '1';
                    s_Task2_Deadline     <= s_Task2_AddOut;
                else
                    o_Task2_Period_Clear <= '0';
                end if;
                if (i_Current_Time >= s_Task3_Deadline) then
                    o_Task3_Period_Clear <= '1';
                    s_Task3_Deadline     <= s_Task3_AddOut;
                else
                    o_Task3_Period_Clear <= '0';
                end if;
                if (i_Current_Time >= s_Task4_Deadline) then
                    o_Task4_Period_Clear <= '1';
                    s_Task4_Deadline     <= s_Task4_AddOut;
                else
                    o_Task4_Period_Clear <= '0';
                end if;
            end if;
        end if;
    end process;

    process (i_Task0_Complete, i_Task1_Complete, i_Task2_Complete, i_Task3_Complete, i_Task4_Complete, i_CLK)
    begin
        --IF (rising_edge(i_CLK)) THEN
        -- if (i_Current_Time = X"00000000") then --Dont write one dead cycle
        --     o_Current_Task_Sel    <= "111";
        --     o_Current_Task_Sel_WE <= '0';
        if (i_Task0_Complete = '0') then
            o_Current_Task_Sel    <= "000";
            o_Current_Task_Sel_WE <= '1';
        elsif (i_Task1_Complete = '0') then
            o_Current_Task_Sel    <= "001";
            o_Current_Task_Sel_WE <= '1';
        elsif (i_Task2_Complete = '0') then
            o_Current_Task_Sel    <= "010";
            o_Current_Task_Sel_WE <= '1';
        elsif (i_Task3_Complete = '0') then
            o_Current_Task_Sel    <= "011";
            o_Current_Task_Sel_WE <= '1';
        elsif (i_Task4_Complete = '0') then
            o_Current_Task_Sel    <= "100";
            o_Current_Task_Sel_WE <= '1';
        else
            o_Current_Task_Sel    <= "111";
            o_Current_Task_Sel_WE <= '0';
        end if;

        --END IF;
    end process;

end mixed;