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
    constant N : integer := 32;
    constant LCM : std_logic_vector(31 downto 0) := X"0000000F";

    component timerCounter is
        generic (N : integer := 32;
                 LCM : std_logic_vector(31 downto 0) := X"00000010"); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_CLK : in std_logic;   -- Clock input
            i_RST : in std_logic;   -- Reset input
            i_WE  : in std_logic;   -- Write enable input
            o_count   : out std_logic_vector(N-1 downto 0);
            o_LCMclear : out std_logic); -- Data value output
            end component;

    -- Input signals of tested module
    signal s_CLK, s_RST, s_WE : std_logic;

    -- Output signals of tested module
    signal o_count : std_logic_vector(N - 1 downto 0);
    signal o_LCMclear : std_logic;

begin

    DUT0 : timerCounter
    generic map(
        N => N,
        LCM => LCM
    )
    port map(
        i_CLK => s_CLK,
        i_RST => s_RST,
        i_WE  => s_WE,
        o_count   => o_count,
        o_LCMclear => o_LCMclear);

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
        s_RST <= '1';
        s_WE <= '0';
        wait for cCLK_PER;

        -- Disable reset
        s_RST <= '0';
        wait for cCLK_PER;

        -- Ensure no counting...
        wait for 4*cCLK_PER;

        -- Start counting
        s_RST <= '0';
        s_WE <= '1';
        wait for 20*cCLK_PER;

        s_RST <= '1';
        s_WE <= '1';
        wait for 3*cCLK_PER;

        s_RST <= '0';
        s_WE <= '0';
        wait for 3*cCLK_PER;


        wait;
    end process;

end behavior;