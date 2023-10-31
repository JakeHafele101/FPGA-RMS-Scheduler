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
        TASK0PERIOD: std_logic_vector(32 - 1 downto 0) := X"00000001";
	    TASK1PERIOD: std_logic_vector(32 - 1 downto 0) := X"00000002";
        TASK2PERIOD: std_logic_vector(32 - 1 downto 0) := X"00000004";
        TASK3PERIOD: std_logic_vector(32 - 1 downto 0) := X"00000008";
        TASK4PERIOD: std_logic_vector(32 - 1 downto 0) := X"00000010");
    port (
        i_CLK        : in std_logic;
        i_Asynch_RST        : in std_logic;
        i_LCM_Clear        : in std_logic;
        i_Task1_Complete        : in std_logic;
        i_Task2_Complete        : in std_logic;
        i_Task3_Complete        : in std_logic;
        i_Task4_Complete        : in std_logic;
        i_Task5_Complete        : in std_logic;
        i_Current_Time : in std_logic_vector(32 - 1 downto 0);
        o_Current_Task_Sel : out std_logic_vector(3 - 1 downto 0);
        o_Task0_Period_Clear: out std_logic;
        o_Task1_Period_Clear: out std_logic;
        o_Task2_Period_Clear: out std_logic;
        o_Task3_Period_Clear: out std_logic;
        o_Task4_Period_Clear: out std_logic;
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
    signal s_current_PC : std_logic_vector(32 - 1 downto 0);
    signal s_Task0_Deadline        : std_logic_vector(32 - 1 downto 0);
    signal s_Task1_Deadline        : std_logic_vector(32 - 1 downto 0);
    signal s_Task2_Deadline        : std_logic_vector(32 - 1 downto 0);
    signal s_Task3_Deadline        : std_logic_vector(32 - 1 downto 0);
    signal s_Task4_Deadline        : std_logic_vector(32 - 1 downto 0);

begin
        process(i_CLK,i_Asynch_RST)
        begin
            if(i_Asynch_RST='1'or (i_LCM_Clear and rising_edge(i_CLK))) then
                s_Task0_Deadline <= TASK0PERIOD;
                s_Task1_Deadline <= TASK1PERIOD;
                s_Task2_Deadline <= TASK2PERIOD;
                s_Task3_Deadline <= TASK3PERIOD;
                s_Task4_Deadline <= TASK4PERIOD;
            end if;
        end process;
        
        process(i_CLK)
        begin
            if(rising_edge(i_CLK)) then
                s_Task0_Deadline <= TASK0PERIOD;
                s_Task1_Deadline <= TASK1PERIOD;
                s_Task2_Deadline <= TASK2PERIOD;
                s_Task3_Deadline <= TASK3PERIOD;
                s_Task4_Deadline <= TASK4PERIOD;
            end if;
        end process;

    process(s_current_PC)
    begin
        if(s_current_PC >= FINAL_PC)then
            o_isComplete <= '1';
        else
            o_isComplete <= '0';
        end if;
    end process;

end mixed;