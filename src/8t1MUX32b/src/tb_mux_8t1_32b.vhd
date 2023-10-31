-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux_8t1_32b.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the mux_8t1_32b unit. The 
-- mux_8t1_32b unit uses a generic (default 16) integer value to create N 
-- 2 to 1 MUX's from the mux2t1 module. This means I will need N i_D0 and 
-- i_D1 bits for the inputs, one select line bit, and N o_O bits
-- 
-- Created 01/20/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
use IEEE.numeric_std.all; -- for std_logic_vector to integer conversion
library std;
use std.textio.all; -- For basic I/O

entity tb_mux_8t1_32b is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_mux_8t1_32b;

architecture mixed of tb_mux_8t1_32b is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    --set component interface of DUT
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

    -- Input signals of tested modules
    signal s_i_S : std_logic_vector(2 downto 0) := "000"; -- 5 bit select line of mux_8t1_32b
    signal s_i_D0 : std_logic_vector(31 downto 0) := x"0000000F";
    signal s_i_D1 : std_logic_vector(31 downto 0) := x"000000F0";
    signal s_i_D2 : std_logic_vector(31 downto 0) := x"00000F00";
    signal s_i_D3 : std_logic_vector(31 downto 0) := x"0000F000";
    signal s_i_D4 : std_logic_vector(31 downto 0) := x"000F0000";
    signal s_i_D5 : std_logic_vector(31 downto 0) := x"00F00000";
    signal s_i_D6 : std_logic_vector(31 downto 0) := x"0F000000";
    signal s_i_D7 : std_logic_vector(31 downto 0) := x"F0000000";

    --Output signals of tested modules
    signal s_o_O : std_logic_vector(31 downto 0);

begin

    -- mux_8t1_32b with 4 mu2t1 modules
    DUT0 : mux_8t1_32b
    port map(
        i_S   => s_i_S, -- All instances share the same select input.
        i_D0  => s_i_D0,
        i_D1  => s_i_D1,
        i_D2  => s_i_D2,
        i_D3  => s_i_D3,
        i_D4  => s_i_D4,
        i_D5  => s_i_D5,
        i_D6  => s_i_D6,
        i_D7  => s_i_D7,
        o_O   => s_o_O);

    P_CONTROL_S0 : process
    begin
        wait for cCLK_PER * 2;
        s_i_S(0) <= not s_i_S(0);
    end process;

    P_CONTROL_S1 : process
    begin
        wait for cCLK_PER * 4;
        s_i_S(1) <= not s_i_S(1);
    end process;

    P_CONTROL_S2 : process
    begin
        wait for cCLK_PER * 8;
        s_i_S(2) <= not s_i_S(2);
    end process;

end mixed;