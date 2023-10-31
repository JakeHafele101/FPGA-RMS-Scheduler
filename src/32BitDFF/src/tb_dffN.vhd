-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_dffN.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered N bit register with parallel access and reset.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dffN is
    generic (gCLK_HPER : time := 10 ns);
end tb_dffN;

architecture behavior of tb_dffN is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- N integer declaraction for DUT instantiation
    constant N : integer := 32;

    component dffN is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_CLK : in std_logic;                          -- Clock input
            i_RST : in std_logic;                          -- Reset input
            i_WE  : in std_logic;                          -- Write enable input
            i_D   : in std_logic_vector(N - 1 downto 0);   --N bit data value input
            o_Q   : out std_logic_vector(N - 1 downto 0)); -- N bit data value output
    end component;

    -- Input signals of tested module
    signal s_CLK, s_RST, s_WE : std_logic;
    signal s_D : std_logic_vector(N - 1 downto 0);

    -- Output signals of tested module
    signal s_Q : std_logic_vector(N - 1 downto 0);

    -- Internal test signals of testbench
    signal s_Q_Mismatch : std_logic := '0';
    signal s_Q_Expected : std_logic_vector(N - 1 downto 0) := X"00000000";

begin

    DUT0 : dffN
    port map(
        i_CLK => s_CLK,
        i_RST => s_RST,
        i_WE  => s_WE,
        i_D   => s_D,
        o_Q   => s_Q);

    -- This process sets the clock value (low for gCLK_HPER, then high
    -- for gCLK_HPER). Absent a "wait" command, processes restart 
    -- at the beginning once they have reached the final statement.
    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    P_MISMATCH : process
    begin
        wait for gCLK_HPER * 1.5; --wait after pos edge for signals to update

        if (s_Q /= s_Q_Expected) then
            s_Q_Mismatch <= '1';
        else 
            s_Q_Mismatch <= '0';
        end if;

        wait for gCLK_HPER / 2;

    end process;

    -- Testbench process  
    P_DUT0 : process
    begin
        -- Reset the FF
        s_RST <= '1';
        s_WE <= '0';
        s_D <= X"00000000";
        s_Q_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Store 0xF492CAB0
        s_RST <= '0';
        s_WE <= '1';
        s_D <= X"F492CAB0";
        s_Q_Expected <= X"F492CAB0";
        wait for cCLK_PER;

        -- Keep 0xF492CAB0
        s_RST <= '0';
        s_WE <= '0';
        s_D <= X"00000000";
        s_Q_Expected <= X"F492CAB0";
        wait for cCLK_PER;

        -- Store '0'    
        s_RST <= '0';
        s_WE <= '1';
        s_D <= X"00000000";
        s_Q_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Keep 0x00000000
        s_RST <= '0';
        s_WE <= '0';
        s_D <= X"00000000";
        s_Q_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Store 0x00000001
        s_RST <= '0';
        s_WE <= '1';
        s_D <= X"00000001";
        s_Q_Expected <= X"00000001";
        wait for cCLK_PER;

        -- Reset the FF
        s_RST <= '1';
        s_WE <= '0';
        s_D <= X"00000000";
        s_Q_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Keep 0x00000000
        s_RST <= '0';
        s_WE <= '0';
        s_D <= X"00000000";
        s_Q_Expected <= X"00000000";
        wait for cCLK_PER;

        wait;
    end process;

end behavior;