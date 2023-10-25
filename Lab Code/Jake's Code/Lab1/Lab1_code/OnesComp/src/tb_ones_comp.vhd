-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ones_comp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the ones_comp unit. The 
-- ones_comp unit uses a generic (default 32) integer value to create N 
-- inverting modules to invert each individual bit of an input. 
-- 
-- Created 01/22/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
library std;
use std.textio.all; -- For basic I/O

entity tb_ones_comp is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_ones_comp;

architecture mixed of tb_ones_comp is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- define N integer constant for each DUT
    constant N0 : integer := 8;
    constant N1 : integer := 16;
    constant N2 : integer := 32;

    --set component interface of DUT
    component ones_comp is
        generic (N : integer := 32); --default 32 bit input
        port (
            i_A : in std_logic_vector ((N - 1) downto 0);   --input to be inverted
            o_F : out std_logic_vector ((N - 1) downto 0)); --inverted output
    end component;

    -- Input signals of tested modules
    signal s_i_A : std_logic_vector((N2 - 1) downto 0) := (others => '0'); --"others => '0'" sets all bits in vector to 0!

    --Output signals of tested modules
    signal s_o_F_DUT0 : std_logic_vector((N0 - 1) downto 0);
    signal s_o_F_DUT1 : std_logic_vector((N1 - 1) downto 0);
    signal s_o_F_DUT2 : std_logic_vector((N2 - 1) downto 0);

begin

    -- ones_comp with 8 mu2t1 modules
    DUT0 : ones_comp
    generic map(N => N0)
    port map(
        i_A => s_i_A((N0 - 1) downto 0),
        o_F => s_o_F_DUT0);

    -- ones_comp with 16 mu2t1 modules
    DUT1 : ones_comp
    generic map(N => N1)
    port map(
        i_A => s_i_A((N1 - 1) downto 0),
        o_F => s_o_F_DUT1);

    -- ones_comp with 32 mu2t1 modules. Don't need to assign generic map since default is 32 bits
    DUT2 : ones_comp
    port map(
        i_A => s_i_A((N2 - 1) downto 0),
        o_F => s_o_F_DUT2);

    --process to test DUT0 with 4 mux2t1 Modules (0 to 15 decimal)
    P_DUT : process
    begin

        s_i_A <= X"00000000"; --in binary 0000 0000 0000 0000 0000 0000 0000 0000
        wait for cCLK_PER; --wait 1 clock cycle (20 ns)

        s_i_A <= X"FFFFFFFF"; --in binary 1111 1111 1111 1111 1111 1111 1111 1111 
        wait for cCLK_PER;

        s_i_A <= X"F0F0F0F0"; --in binary 1111 0000 1111 0000 1111 0000 1111 0000 
        wait for cCLK_PER;

        s_i_A <= X"0F0F0F0F"; --in binary 0000 1111 0000 1111 0000 1111 0000 1111
        wait for cCLK_PER;

        s_i_A <= X"4A08C23E"; --in binary 0100 1010 0000 1000 1100 0010 0011 1110
        wait for cCLK_PER;

        wait;

    end process;

end mixed;