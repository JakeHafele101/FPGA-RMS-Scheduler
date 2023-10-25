-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level register file reg_file.vhd
--
--
-- NOTES:
-- Created 2/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.arrays.all;

entity tb_reg_file is
    generic (gCLK_HPER : time := 10 ns);
end tb_reg_file;

architecture mixed of tb_reg_file is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component reg_file is
        port (
            i_CLK     : in std_logic;                       -- Clock input
            i_RST     : in std_logic;                       -- Reset input
            i_RS      : in std_logic_vector(4 downto 0);    -- RS first operand reg num
            i_RT      : in std_logic_vector(4 downto 0);    -- RT second operand reg num
            i_RD      : in std_logic_vector(4 downto 0);    -- Write enable input
            i_RD_WE   : in std_logic;                       -- Write enable for destination reg RD
            i_RD_DATA : in std_logic_vector(31 downto 0);   -- RD destination reg to write to
            o_RS_DATA : out std_logic_vector(31 downto 0);  -- RS reg data output
            o_RT_DATA : out std_logic_vector(31 downto 0)); -- RT reg data output
    end component;

    -- Input signals of tested module
    signal s_CLK, s_RST, s_i_RD_WE : std_logic := '0';
    signal s_i_RS, s_i_RT, s_i_RD : std_logic_vector(4 downto 0) := "00000";
    signal s_i_RD_DATA : std_logic_vector(31 downto 0) := X"00000000";

    -- Output signals of tested module
    signal s_o_RS_DATA, s_o_RT_DATA : std_logic_vector(31 downto 0);

    -- Internal test signals of testbench
    signal s_RS_Expected, s_RT_Expected : std_logic_vector(31 downto 0) := X"00000000";
    signal s_RS_Mismatch, s_RT_Mismatch : std_logic := '0';

begin

    DUT0 : reg_file
    port map(
        i_CLK     => s_CLK,
        i_RST     => s_RST,
        i_RS      => s_i_RS,
        i_RT      => s_i_RT,
        i_RD      => s_i_RD,
        i_RD_WE   => s_i_RD_WE,
        i_RD_DATA => s_i_RD_DATA,
        o_RS_DATA => s_o_RS_DATA,
        o_RT_DATA => s_o_RT_DATA);

    -- Clock period
    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    --Expected vs actual check
    P_MISMATCH : process
    begin
        wait for gCLK_HPER * 1.5; --wait after pos edge for signals to update

        if (s_o_RS_DATA /= s_RS_Expected) then
            report "RS_Data error at time " & time'image(now);
            s_RS_Mismatch <= '1';
        else
            s_RS_Mismatch <= '0';
        end if;

        if (s_o_RT_DATA /= s_RT_Expected) then
            report "RT_Data error at time " & time'image(now);
            s_RT_Mismatch <= '1';
        else
            s_RT_Mismatch <= '0';
        end if;

        wait for gCLK_HPER / 2;

    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- Reset reg file
        s_RST <= '1';
        s_i_RS <= "00000";
        s_i_RT <= "00000";
        s_i_RD <= "00000";
        s_i_RD_WE <= '0';
        s_i_RD_DATA <= X"00000000";
        s_RS_Expected <= X"00000000";
        s_RT_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Attempt to write 0xFFFFFFFF to register 0 (should stay 0x00000000)
        s_RST <= '0';
        s_i_RS <= "00000";
        s_i_RT <= "00000";
        s_i_RD <= "00000";
        s_i_RD_WE <= '1';
        s_i_RD_DATA <= X"FFFFFFFF";
        s_RS_Expected <= X"00000000";
        s_RT_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Write 0xFFFFFFFF to register 5, verify output displayed
        s_RST <= '0';
        s_i_RS <= "00101";
        s_i_RT <= "00000";
        s_i_RD <= "00101";
        s_i_RD_WE <= '1';
        s_i_RD_DATA <= X"FFFFFFFF";
        s_RS_Expected <= X"FFFFFFFF";
        s_RT_Expected <= X"00000000";
        wait for cCLK_PER;

        -- Write 0x12345678 to register 31, verify output displayed
        s_RST <= '0';
        s_i_RS <= "00101";
        s_i_RT <= "11111";
        s_i_RD <= "11111";
        s_i_RD_WE <= '1';
        s_i_RD_DATA <= X"12345678";
        s_RS_Expected <= X"FFFFFFFF";
        s_RT_Expected <= X"12345678";
        wait for cCLK_PER;

        -- read RS in another reg
        s_RST <= '0';
        s_i_RS <= "00001";
        s_i_RT <= "11111";
        s_i_RD <= "11111";
        s_i_RD_WE <= '0';
        s_i_RD_DATA <= X"00000000";
        s_RS_Expected <= X"00000000";
        s_RT_Expected <= X"12345678";
        wait for cCLK_PER;

        --Reset reg file, verify all set to 0
        s_RST <= '1';
        s_i_RS <= "00001";
        s_i_RT <= "11111";
        s_i_RD <= "11111";
        s_i_RD_WE <= '0';
        s_i_RD_DATA <= X"00000000";
        s_RS_Expected <= X"00000000";
        s_RT_Expected <= X"00000000";
        wait for cCLK_PER;

        wait;
    end process;

end mixed;