-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_decoder_3t8.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the decoder_5t32 unit.
-- 
-- Created 01/22/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
library std;
use std.textio.all; -- For basic I/O

entity tb_decoder_3t8 is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_decoder_3t8;

architecture mixed of tb_decoder_3t8 is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- Define component interface.
    component decoder_3t8 is
        port (
            i_A   : in std_logic_vector(2 downto 0);    --5 bit data value input
            i_WE  : in std_logic; 
            o_F   : out std_logic_vector(7 downto 0)); -- 32 bit data value output
    end component;

    -- Input of tested module
    signal s_i_A : std_logic_vector(2 downto 0) := "000";
    signal s_i_WE : std_logic := '0';

    -- Output signals of tested module
    signal s_o_F : std_logic_vector(7 downto 0);

begin

    -- instantiate decoder_5t32 component as DUT0 (Design Under Test)
    DUT0 : decoder_3t8
    port map(
        i_A    => s_i_A,
        i_WE   => s_i_WE,
        o_F    => s_o_F);

    P_CONTROL_A0 : process
    begin
        wait for cCLK_PER * 2;
        s_i_A(0) <= not s_i_A(0);
    end process;

    P_CONTROL_A1 : process
    begin
        wait for cCLK_PER * 4;
        s_i_A(1) <= not s_i_A(1);
    end process;

    P_CONTROL_A2 : process
    begin
        wait for cCLK_PER * 8;
        s_i_A(2) <= not s_i_A(2);
    end process;

    P_CONTROL_WE : process
    begin
        wait for cCLK_PER * 16;
        s_i_WE <= not s_i_WE;
    end process;

end mixed;