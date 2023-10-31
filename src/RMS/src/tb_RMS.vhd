-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_timerCounter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered N bit register with parallel access and reset.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_timerCounter is
    generic (gCLK_HPER : time := 10 ns);
end tb_timerCounter;

architecture behavior of tb_timerCounter is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- N integer declaraction for DUT instantiation
    constant N   : integer                       := 32;
    constant LCM : std_logic_vector(31 downto 0) := X"0000000F";

    component timerCounter is
        generic (
            TASK0PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000001";
            TASK1PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000002";
            TASK2PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000004";
            TASK3PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000008";
            TASK4PERIOD : std_logic_vector(32 - 1 downto 0) := X"00000010";

            TASK0_INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            TASK1_INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            TASK2_INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            TASK3_INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            TASK4_INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";

            TASK0_FINAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000004";
            TASK1_FINAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000004";
            TASK2_FINAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000004";
            TASK3_FINAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000004";
            TASK4_FINAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000004";

            LCM : std_logic_vector(31 downto 0) := X"0000000F"
        );
        port (
            i_CLK        : in std_logic;                         --Global clock
            i_Asynch_RST : in std_logic;                         --Global async reset, active high
            i_dffN_incr  : in std_logic_vector(32 - 1 downto 0); --Increment amount to add to PC for active task
            i_PC_incr    : in std_logic_vector(32 - 1 downto 0); --Increment amount to add to PC for active task

            -- Time counter
            o_time     : out std_logic_vector(32 - 1 downto 0);
            o_LCMclear : out std_logic

            -- Task Control
            --Task Controls
            o_Current_Task_Sel    : out std_logic_vector(3 - 1 downto 0);
            o_Current_Task_Sel_WE : out std_logic

            o_Task0_Period_Clear : out std_logic;
            o_Task1_Period_Clear : out std_logic;
            o_Task2_Period_Clear : out std_logic;
            o_Task3_Period_Clear : out std_logic;
            o_Task4_Period_Clear : out std_logic;

            --Task State Registers
            --Current PC counters
            o_task0_currentPC : out std_logic_vector(32 - 1 downto 0);
            o_task1_currentPC : out std_logic_vector(32 - 1 downto 0);
            o_task2_currentPC : out std_logic_vector(32 - 1 downto 0);
            o_task3_currentPC : out std_logic_vector(32 - 1 downto 0);
            o_task4_currentPC : out std_logic_vector(32 - 1 downto 0);

            --Current PC counters
            o_task0_dffN_Q : out std_logic_vector(32 - 1 downto 0);
            o_task1_dffN_Q : out std_logic_vector(32 - 1 downto 0);
            o_task2_dffN_Q : out std_logic_vector(32 - 1 downto 0);
            o_task3_dffN_Q : out std_logic_vector(32 - 1 downto 0);
            o_task4_dffN_Q : out std_logic_vector(32 - 1 downto 0);

            -- Task is complete for period
            o_task0_isComplete : out std_logic;
            o_task1_isComplete : out std_logic;
            o_task2_isComplete : out std_logic;
            o_task3_isComplete : out std_logic;
            o_task4_isComplete : out std_logic);

    end component;

    -- Input signals of tested module
    signal s_CLK, s_RST           : std_logic;
    signal s_dffN_incr, s_PC_incr : std_logic_vector(31 downto 0);

    -- Output signals of tested module
    signal o_time     : std_logic_vector(32 - 1 downto 0);
    signal o_LCMclear : std_logic;

    signal o_Current_Task_Sel    : std_logic_vector(2 downto 0);
    signal o_Current_Task_Sel_WE : std_logic;

    signal o_task_period_clear : std_logic_vector(4 downto 0);
    signal o_task_isComplete   : std_logic_vector(4 downto 0);

    signal o_task0_currentPC : std_logic_vector(31 downto 0);
    signal o_task1_currentPC : std_logic_vector(31 downto 0);
    signal o_task2_currentPC : std_logic_vector(31 downto 0);
    signal o_task3_currentPC : std_logic_vector(31 downto 0);
    signal o_task4_currentPC : std_logic_vector(31 downto 0);

    signal o_task0_dffN_Q : std_logic_vector(31 downto 0);
    signal o_task1_dffN_Q : std_logic_vector(31 downto 0);
    signal o_task2_dffN_Q : std_logic_vector(31 downto 0);
    signal o_task3_dffN_Q : std_logic_vector(31 downto 0);
    signal o_task4_dffN_Q : std_logic_vector(31 downto 0);

begin

    DUT0 : RMS
    generic map(
        TASK0PERIOD => FIXME,
        TASK1PERIOD => FIXME,
        TASK2PERIOD => FIXME,
        TASK3PERIOD => FIXME,
        TASK4PERIOD => FIXME,

        TASK0_INITIAL_PC => FIXME,
        TASK1_INITIAL_PC => FIXME,
        TASK2_INITIAL_PC => FIXME,
        TASK3_INITIAL_PC => FIXME,
        TASK4_INITIAL_PC => FIXME,

        TASK0_FINAL_PC => FIXME,
        TASK1_FINAL_PC => FIXME,
        TASK2_FINAL_PC => FIXME,
        TASK3_FINAL_PC => FIXME,
        TASK4_FINAL_PC => FIXME,

        LCM => FIXME,
    )
    port map(
        i_CLK        => s_CLK,
        i_Asynch_RST => s_RST,
        i_dffN_incr  => s_dffN_incr,
        i_PC_incr    => s_PC_incr,

        o_time     => FIXME,
        o_LCMclear => FIXME,

        o_Current_Task_Sel    => o_Current_Task_Sel,
        o_Current_Task_Sel_WE => o_Current_Task_Sel_WE,

        o_Task0_Period_Clear => o_task_period_clear(0),
        o_Task1_Period_Clear => o_task_period_clear(1),
        o_Task2_Period_Clear => o_task_period_clear(2),
        o_Task3_Period_Clear => o_task_period_clear(3),
        o_Task4_Period_Clear => o_task_period_clear(4),

        o_task0_currentPC => o_task0_currentPC,
        o_task1_currentPC => o_task1_currentPC,
        o_task2_currentPC => o_task2_currentPC,
        o_task3_currentPC => o_task3_currentPC,
        o_task4_currentPC => o_task4_currentPC,

        o_task0_dffN_Q => o_task0_dffN_Q,
        o_task1_dffN_Q => o_task1_dffN_Q,
        o_task2_dffN_Q => o_task2_dffN_Q,
        o_task3_dffN_Q => o_task3_dffN_Q,
        o_task4_dffN_Q => o_task4_dffN_Q,

        o_task0_isComplete => o_task_isComplete(0),
        o_task1_isComplete => o_task_isComplete(1),
        o_task2_isComplete => o_task_isComplete(2),
        o_task3_isComplete => o_task_isComplete(3),
        o_task4_isComplete => o_task_isComplete(4),
    );

    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    -- Testbench process  
    P_DUT0 : process
    begin
        -- Reset the FF
        s_RST       <= '1';
        s_WE        <= '0';
        s_dffN_incr <= X"00000001";
        s_PC_incr   <= X"00000004";
        wait for cCLK_PER;

        -- Disable reset
        s_RST <= '0';
        wait for cCLK_PER;

        -- Ensure no counting...
        wait for 40 * cCLK_PER;

        wait; --We are done, hooray (?)
    end process;

end behavior;