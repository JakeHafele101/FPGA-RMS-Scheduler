library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
use ieee.numeric_std.all;
library std;
use std.textio.all; -- For basic I/O

entity tb_TaskStateReg is
    generic (gCLK_HPER : time := 10 ns);
end tb_TaskStateReg;

architecture behavior of tb_TaskStateReg is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component TaskStateReg
        generic (
            INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
            FINAL_PC   : std_logic_vector(32 - 1 downto 0) := X"00000010");
        port (
            i_CLK          : in std_logic;
            i_Asynch_RST   : in std_logic;
            i_next_PC      : in std_logic_vector(32 - 1 downto 0);
            i_next_PC_WE   : in std_logic;
            i_Period_Clear : in std_logic;
            o_current_PC   : out std_logic_vector(32 - 1 downto 0);
            o_isComplete   : out std_logic);
    end component;

    signal s_CLK          : std_logic;
    signal s_Asynch_RST   : std_logic;
    signal s_next_PC      : std_logic_vector(32 - 1 downto 0);
    signal s_next_PC_WE   : std_logic;
    signal s_Period_Clear : std_logic;
    signal s_current_PC   : std_logic_vector(32 - 1 downto 0);
    signal s_isComplete   : std_logic;
begin
    DUT0 : TaskStateReg
    port map(
        i_CLK          => s_CLK,
        i_Asynch_RST   => s_Asynch_RST,
        i_next_PC      => s_next_PC,
        i_next_PC_WE   => s_next_PC_WE,
        i_Period_Clear => s_Period_Clear,
        o_current_PC   => s_current_PC,
        o_isComplete   => s_isComplete);

    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    -- Testbench process  
    P_TB : process
    begin
        wait for cCLK_PER/4;
        s_Period_Clear <= '0';
        s_Asynch_RST   <= '1';
        wait for cCLK_PER;
        s_Asynch_RST <= '0';
        s_next_PC_WE <= '0';
        s_next_PC    <= std_logic_vector(to_unsigned(4, s_next_PC'length));

        wait for cCLK_PER;
        s_next_PC_WE <= '1';
        wait for cCLK_PER;
        s_next_PC <= std_logic_vector(to_unsigned(8, s_next_PC'length));
        wait for cCLK_PER;
        s_next_PC <= std_logic_vector(to_unsigned(12, s_next_PC'length));
        wait for cCLK_PER;
        s_next_PC <= std_logic_vector(to_unsigned(16, s_next_PC'length));
        wait for cCLK_PER;
        s_next_PC <= std_logic_vector(to_unsigned(20, s_next_PC'length));
        wait for cCLK_PER;
        s_next_PC_WE <= '0';
        wait for cCLK_PER;
        s_next_PC <= std_logic_vector(to_unsigned(13, s_next_PC'length));
        wait for cCLK_PER;
        s_Period_Clear <= '1';
        wait for cCLK_PER;
        s_Period_Clear <= '0';
        s_next_PC_WE   <= '1';
        s_next_PC      <= std_logic_vector(to_unsigned(4, s_next_PC'length));
        wait for cCLK_PER;
        wait for cCLK_PER;
        s_Asynch_RST <= '1';
        wait for cCLK_PER;

    end process;

end behavior;