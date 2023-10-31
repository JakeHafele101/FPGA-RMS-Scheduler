-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder_subber.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a task state register
-- for a single task for a RMS hardware Scheduler
--
-- 
-- Created 10/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity RMS is
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
        i_PC_incr    : in std_logic_vector(32 - 1 downto 0); --Increment amount to add to PC for active task
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

        -- Task is complete for period
        o_task0_isComplete : out std_logic;
        o_task1_isComplete : out std_logic;
        o_task2_isComplete : out std_logic;
        o_task3_isComplete : out std_logic;
        o_task4_isComplete : out std_logic);
end RMS;

architecture mixed of RMS is

    component TaskStateReg is
        generic (
            INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            FINAL_PC   : std_logic_vector(32 - 1 downto 0) := X"00000000");
        port (
            i_CLK          : in std_logic;
            i_Asynch_RST   : in std_logic;
            i_next_PC      : in std_logic_vector(32 - 1 downto 0);
            i_next_PC_WE   : in std_logic;
            i_Period_Clear : in std_logic;
            o_current_PC   : out std_logic_vector(32 - 1 downto 0);
            o_isComplete   : out std_logic);
    end component;

    component TaskControl is
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
    end component;

    component timerCounter is
        generic (
            N   : integer                       := 32;
            LCM : std_logic_vector(31 downto 0) := X"0000000F"); -- Set to 1 less than LCM
        port (
            i_CLK      : in std_logic; -- Clock input
            i_RST      : in std_logic; -- Reset input
            i_WE       : in std_logic; -- Write enable input
            o_count    : out std_logic_vector(N - 1 downto 0);
            o_LCMclear : out std_logic); -- Data value output
    end component;

    component ripple_adder is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_X    : in std_logic_vector(N - 1 downto 0);
            i_Y    : in std_logic_vector(N - 1 downto 0);
            i_Cin  : in std_logic;
            o_S    : out std_logic_vector(N - 1 downto 0);
            o_Cout : out std_logic);
    end component;

    component dffN is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_CLK : in std_logic;                          -- Clock input
            i_RST : in std_logic;                          -- Reset input
            i_WE  : in std_logic;                          -- Write enable input
            i_D   : in std_logic_vector(N - 1 downto 0);   -- Data value input
            o_Q   : out std_logic_vector(N - 1 downto 0)); -- Data value output      
    end component;

    component mux_8t1_32b is
        port (
            i_S  : in std_logic_vector(2 downto 0);
            i_D0 : in std_logic_vector(31 downto 0);
            i_D1 : in std_logic_vector(31 downto 0);
            i_D2 : in std_logic_vector(31 downto 0);
            i_D3 : in std_logic_vector(31 downto 0);
            i_D4 : in std_logic_vector(31 downto 0);
            i_D5 : in std_logic_vector(31 downto 0);
            i_D6 : in std_logic_vector(31 downto 0);
            i_D7 : in std_logic_vector(31 downto 0);
            o_O  : out std_logic_vector(31 downto 0));
    end component;

    component decoder_3t8 is
        port (
            i_A  : in std_logic_vector(2 downto 0); --5 bit data value input
            i_WE : in std_logic;
            o_F  : out std_logic_vector(7 downto 0)); -- 32 bit data value output
    end component;

    -- Control Module
    signal s_task_sel : std_logic_vector(2 downto 0);

    -- Task State Reg Internal Wires
    signal s_next_PC_WE   : std_logic_vector(4 downto 0);
    signal s_Period_Clear : std_logic_vector(4 downto 0);
    signal s_isComplete   : std_logic_vector(4 downto 0);

    signal s_task0_next_PC : std_logic_vector(31 downto 0);
    signal s_task1_next_PC : std_logic_vector(31 downto 0);
    signal s_task2_next_PC : std_logic_vector(31 downto 0);
    signal s_task3_next_PC : std_logic_vector(31 downto 0);
    signal s_task4_next_PC : std_logic_vector(31 downto 0);

    signal s_task0_current_PC : std_logic_vector(31 downto 0);
    signal s_task1_current_PC : std_logic_vector(31 downto 0);
    signal s_task2_current_PC : std_logic_vector(31 downto 0);
    signal s_task3_current_PC : std_logic_vector(31 downto 0);
    signal s_task4_current_PC : std_logic_vector(31 downto 0);

    --Task State DFFNs
    signal s_dffN_WE : std_logic_vector(4 downto 0);

    signal s_task0_dffN_Q : std_logic_vector(31 downto 0);
    signal s_task1_dffN_Q : std_logic_vector(31 downto 0);
    signal s_task2_dffN_Q : std_logic_vector(31 downto 0);
    signal s_task3_dffN_Q : std_logic_vector(31 downto 0);
    signal s_task4_dffN_Q : std_logic_vector(31 downto 0);

    -- DFF Task Adder
    signal s_dffN_DATA_MUX : std_logic_vector(31 downto 0);
    signal s_dffN_DATA_WB  : std_logic_vector(31 downto 0);

begin

    g_task0_TaskStateReg : TaskStateReg
    generic map(
        INITIAL_PC => TASK0_INITIAL_PC,
        FINAL_PC   => TASK0_FINAL_PC
    )
    port map(
        i_CLK          => i_CLK,
        i_Asynch_RST   => i_Asynch_RST,
        i_next_PC      => s_task0_next_PC,
        i_next_PC_WE   => s_next_PC_WE(0),
        i_Period_Clear => s_Period_Clear(0),
        o_current_PC   => s_task0_current_PC,
        o_isComplete   => s_isComplete(0));

    g_task1_TaskStateReg : TaskStateReg
    generic map(
        INITIAL_PC => TASK1_INITIAL_PC,
        FINAL_PC   => TASK1_FINAL_PC
    )
    port map(
        i_CLK          => i_CLK,
        i_Asynch_RST   => i_Asynch_RST,
        i_next_PC      => s_task1_next_PC,
        i_next_PC_WE   => s_next_PC_WE(1),
        i_Period_Clear => s_Period_Clear(1),
        o_current_PC   => s_task1_current_PC,
        o_isComplete   => s_isComplete(1));

    g_task2_TaskStateReg : TaskStateReg
    generic map(
        INITIAL_PC => TASK2_INITIAL_PC,
        FINAL_PC   => TASK2_FINAL_PC
    )
    port map(
        i_CLK          => i_CLK,
        i_Asynch_RST   => i_Asynch_RST,
        i_next_PC      => s_task2_next_PC,
        i_next_PC_WE   => s_next_PC_WE(2),
        i_Period_Clear => s_Period_Clear(2),
        o_current_PC   => s_task2_current_PC,
        o_isComplete   => s_isComplete(2));

    g_task3_TaskStateReg : TaskStateReg
    generic map(
        INITIAL_PC => TASK3_INITIAL_PC,
        FINAL_PC   => TASK3_FINAL_PC
    )
    port map(
        i_CLK          => i_CLK,
        i_Asynch_RST   => i_Asynch_RST,
        i_next_PC      => s_task3_next_PC,
        i_next_PC_WE   => s_next_PC_WE(3),
        i_Period_Clear => s_Period_Clear(3),
        o_current_PC   => s_task3_current_PC,
        o_isComplete   => s_isComplete(3));

    g_task4_TaskStateReg : TaskStateReg
    generic map(
        INITIAL_PC => TASK4_INITIAL_PC,
        FINAL_PC   => TASK4_FINAL_PC
    )
    port map(
        i_CLK          => i_CLK,
        i_Asynch_RST   => i_Asynch_RST,
        i_next_PC      => s_task4_next_PC,
        i_next_PC_WE   => s_next_PC_WE(4),
        i_Period_Clear => s_Period_Clear(4),
        o_current_PC   => s_task0_current_PC,
        o_isComplete   => s_isComplete(4));

    g_task0_dffN : dffN
    port map(
        i_CLK => i_CLK,
        i_RST => i_Asynch_RST,
        i_WE  => s_dffN_WE(0),    --Comes from decoder
        i_D   => s_dffN_DATA,     --Output of adder from selected task
        o_Q   => s_task0_dffN_Q); --Output of DFF

    g_task1_dffN : dffN
    port map(
        i_CLK => i_CLK,
        i_RST => i_Asynch_RST,
        i_WE  => s_dffN_WE(1),    --Comes from decoder
        i_D   => s_dffN_DATA,     --Output of adder from selected task
        o_Q   => s_task1_dffN_Q); --Output of DFF

    g_task2_dffN : dffN
    port map(
        i_CLK => i_CLK,
        i_RST => i_Asynch_RST,
        i_WE  => s_dffN_WE(2),    --Comes from decoder
        i_D   => s_dffN_DATA,     --Output of adder from selected task
        o_Q   => s_task2_dffN_Q); --Output of DFF

    g_task3_dffN : dffN
    port map(
        i_CLK => i_CLK,
        i_RST => i_Asynch_RST,
        i_WE  => s_dffN_WE(3),    --Comes from decoder
        i_D   => s_dffN_DATA,     --Output of adder from selected task
        o_Q   => s_task3_dffN_Q); --Output of DFF

    g_task4_dffN : dffN
    port map(
        i_CLK => i_CLK,
        i_RST => i_Asynch_RST,
        i_WE  => s_dffN_WE(4),    --Comes from decoder
        i_D   => s_dffN_DATA,     --Output of adder from selected task
        o_Q   => s_task4_dffN_Q); --Output of DFF

    g_dffN_MUX : mux_8t1_32b
    port map(
        i_S  => s_task_sel,
        i_D0 => s_task0_dffN_Q,
        i_D1 => s_task1_dffN_Q,
        i_D2 => s_task2_dffN_Q,
        i_D3 => s_task3_dffN_Q,
        i_D4 => s_task4_dffN_Q,
        i_D5 => X"00000000", --Not Used
        i_D6 => X"00000000", --Not Used
        i_D7 => X"00000000", --Not Used
        o_O  => s_dffN_DATA_MUX);

    g_dffN_ripple : ripple_adder
    port map(
        i_X    => i_CLK,
        i_Y    => i_Asynch_RST,
        i_Cin  => '0',
        o_S    => s_dffN_DATA,
        o_Cout => open);
end mixed;