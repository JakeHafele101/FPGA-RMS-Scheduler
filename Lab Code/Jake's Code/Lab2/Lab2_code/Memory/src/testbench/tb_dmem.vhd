-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_dmem.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- memory file dmem.vhd
--
--
-- NOTES:
-- Created 2/3/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dmem is
    generic (gCLK_HPER : time := 10 ns);
end tb_dmem;

architecture mixed of tb_dmem is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    constant DATA_WIDTH : natural := 32;
    constant ADDR_WIDTH : natural := 10;

    component dmem is
        generic (
            DATA_WIDTH : natural := 32; -- Width of bits for each i_ADDRess
            ADDR_WIDTH : natural := 10 -- Width of i_ADDRess as 2^(ADDR_WIDTH - 1)
        );
        port (
            i_CLK  : in std_logic;
            i_ADDR : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
            i_DATA : in std_logic_vector((DATA_WIDTH - 1) downto 0);
            i_WE   : in std_logic := '1';
            o_Q    : out std_logic_vector((DATA_WIDTH - 1) downto 0)
        );
    end component;

    -- Input signals of tested module
    signal i_CLK, i_WE : std_logic := '0';
    signal i_ADDR : std_logic_vector((ADDR_WIDTH - 1) downto 0);
    signal i_DATA : std_logic_vector((DATA_WIDTH - 1) downto 0);

    -- Output signals of tested module
    signal o_Q : std_logic_vector((DATA_WIDTH - 1) downto 0);

    -- Test signals
    signal s_Q_Expected : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal s_Q_Mismatch : std_logic := '0';
begin

    DUT0 : dmem
    port map(
        i_CLK  => i_CLK,
        i_ADDR => i_ADDR,
        i_DATA => i_DATA,
        i_WE   => i_WE,
        o_Q    => o_Q);

    -- Clock period
    P_CLK : process
    begin
        i_CLK <= '0';
        wait for gCLK_HPER;
        i_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    P_MISMATCH : process
    begin
        wait for gCLK_HPER * 1.5; --wait after pos edge for signals to update

        if (o_Q /= s_Q_Expected) then
            report "Q error at time " & time'image(now);
            s_Q_Mismatch <= '1';
        else
            s_Q_Mismatch <= '0';
        end if;

        wait for gCLK_HPER / 2;

    end process;

    -- Testbench process  
    P_DMEM : process
    begin

        -- Part ii, read initial 10 values stored in memory
        -- read -1 at 0x0000000000
        i_ADDR <= "0000000000";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFFF"; -- (-1)
        wait for cCLK_PER;

        -- read 2 at 0x0000000001
        i_ADDR <= "0000000001";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000002"; -- 2
        wait for cCLK_PER;

        -- read -3 at 0x0000000002
        i_ADDR <= "0000000010";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFFD"; -- (-3)
        wait for cCLK_PER;

        -- read 4 at 0x0000000003
        i_ADDR <= "0000000011";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000004"; -- 4
        wait for cCLK_PER;

        -- read 5 at 0x0000000004
        i_ADDR <= "0000000100";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000005"; -- 5
        wait for cCLK_PER;

        -- read 6 at 0x0000000005
        i_ADDR <= "0000000101";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000006"; -- 6
        wait for cCLK_PER;

        -- read -7 at 0x0000000006
        i_ADDR <= "0000000110";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF9"; -- (-7)
        wait for cCLK_PER;

        -- read -8 at 0x0000000007
        i_ADDR <= "0000000111";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF8"; -- (-8)
        wait for cCLK_PER;

        -- read 9 at 0x0000000008
        i_ADDR <= "0000001000";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000009"; -- 9
        wait for cCLK_PER;

        -- read -10 at 0x0000000009
        i_ADDR <= "0000001001";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF6"; -- (-10)
        wait for cCLK_PER;

        -- Part iii, write same values back to consecutive locations, starting at 0x100
        -- write -1 at 0x100
        i_ADDR <= "0100000000"; --0x100
        i_DATA <= X"FFFFFFFF";
        i_WE <= '1';
        s_Q_Expected <= X"FFFFFFFF"; -- (-1)
        wait for cCLK_PER;

        -- write 2 at 0x101
        i_ADDR <= "0100000001";
        i_DATA <= X"00000002";
        i_WE <= '1';
        s_Q_Expected <= X"00000002"; -- 2
        wait for cCLK_PER;

        -- write -3 at 0x102
        i_ADDR <= "0100000010";
        i_DATA <= X"FFFFFFFD";
        i_WE <= '1';
        s_Q_Expected <= X"FFFFFFFD"; -- (-3)
        wait for cCLK_PER;

        -- write 4 at 0x103
        i_ADDR <= "0100000011";
        i_DATA <= X"00000004";
        i_WE <= '1';
        s_Q_Expected <= X"00000004"; -- 4
        wait for cCLK_PER;

        -- write 5 at 0x104
        i_ADDR <= "0100000100";
        i_DATA <= X"00000005";
        i_WE <= '1';
        s_Q_Expected <= X"00000005"; -- 5
        wait for cCLK_PER;

        -- write 6 at 0x105
        i_ADDR <= "0100000101";
        i_DATA <= X"00000006";
        i_WE <= '1';
        s_Q_Expected <= X"00000006"; -- 6
        wait for cCLK_PER;

        -- write -7 at 0x106
        i_ADDR <= "0100000110";
        i_DATA <= X"FFFFFFF9";
        i_WE <= '1';
        s_Q_Expected <= X"FFFFFFF9"; -- (-7)
        wait for cCLK_PER;

        -- write (-8) at 0x107
        i_ADDR <= "0100000111";
        i_DATA <= X"FFFFFFF8";
        i_WE <= '1';
        s_Q_Expected <= X"FFFFFFF8"; -- (-8)
        wait for cCLK_PER;

        -- write 9 at 0x108
        i_ADDR <= "0100001000";
        i_DATA <= X"00000009";
        i_WE <= '1';
        s_Q_Expected <= X"00000009"; -- 9
        wait for cCLK_PER;

        -- write (-10) at 0x109
        i_ADDR <= "0100001001";
        i_DATA <= X"FFFFFFF6";
        i_WE <= '1';
        s_Q_Expected <= X"FFFFFFF6"; -- (-10)
        wait for cCLK_PER;

        -- Part iv, read new values back to ensure written properly
        -- read -1 at 0x100
        i_ADDR <= "0100000000"; --0x100
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFFF"; -- (-1)
        wait for cCLK_PER;

        -- read 2 at 0x101
        i_ADDR <= "0100000001";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000002"; -- 2
        wait for cCLK_PER;

        -- read -3 at 0x102
        i_ADDR <= "0100000010";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFFD"; -- (-3)
        wait for cCLK_PER;

        -- read 4 at 0x103
        i_ADDR <= "0100000011";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000004"; -- 4
        wait for cCLK_PER;

        -- read 5 at 0x104
        i_ADDR <= "0100000100";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000005"; -- 5
        wait for cCLK_PER;

        -- read 6 at 0x105
        i_ADDR <= "0100000101";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000006"; -- 6
        wait for cCLK_PER;

        -- read -7 at 0x106
        i_ADDR <= "0100000110";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF9"; -- (-7)
        wait for cCLK_PER;

        -- read (-8) at 0x107
        i_ADDR <= "0100000111";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF8"; -- (-8)
        wait for cCLK_PER;

        -- read 9 at 0x108
        i_ADDR <= "0100001000";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"00000009"; -- 9
        wait for cCLK_PER;

        -- read (-10) at 0x109
        i_ADDR <= "0100001001";
        i_DATA <= X"00000000";
        i_WE <= '0';
        s_Q_Expected <= X"FFFFFFF6"; -- (-10)
        wait for cCLK_PER;

        wait;
    end process;

end mixed;