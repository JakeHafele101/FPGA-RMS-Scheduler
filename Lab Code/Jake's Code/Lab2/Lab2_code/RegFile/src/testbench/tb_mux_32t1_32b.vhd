-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux_32t1_32b.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the mux_32t1_32b unit. The 
-- mux_32t1_32b unit uses a generic (default 16) integer value to create N 
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
use work.arrays.all;

entity tb_mux_32t1_32b is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_mux_32t1_32b;

architecture mixed of tb_mux_32t1_32b is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    --set component interface of DUT
    component mux_32t1_32b is
        port (
            i_S : in std_logic_vector(4 downto 0);
            i_D : in word_array(31 downto 0); --32, 32 bit wide std_logic_vectors w
            o_O : out std_logic_vector(31 downto 0));
    end component;

    -- Input signals of tested modules
    signal s_i_S : std_logic_vector(4 downto 0) := "00000"; -- 5 bit select line of mux_32t1_32b
    signal s_i_D : word_array(31 downto 0);

    --Output signals of tested modules
    signal s_o_O : std_logic_vector(31 downto 0);

    -- Internal test signals
    signal s_Word : std_logic_vector(31 downto 0) := X"00000001";

begin

    --assign s_i_D
    P_ASSIGN_HEX : process
    begin
        for i in 0 to 31 loop
            s_i_D(i) <= s_Word(31 downto 0);
            s_Word <= s_Word(30 downto 0) & '0'; --shift by one bit (multiply by 2)
            wait for 1 ns;
        end loop;
        wait;
    end process;


    -- mux_32t1_32b with 4 mu2t1 modules
    DUT0 : mux_32t1_32b
    port map(
        i_S   => s_i_S, -- All instances share the same select input.
        i_D  => s_i_D,
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

    P_CONTROL_S3 : process
    begin
        wait for cCLK_PER * 16;
        s_i_S(3) <= not s_i_S(3);
    end process;

    P_CONTROL_S4 : process
    begin
        wait for cCLK_PER * 32;
        s_i_S(4) <= not s_i_S(4);
    end process;

end mixed;