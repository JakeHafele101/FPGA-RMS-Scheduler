-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_full_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the full_adder unit. The
-- testbench uses three different processes to alternate i_X, i_Y, and 
-- i_Cin at staggered times to recreate the truth table to verify all 
-- combinational options
-- 
-- Created 01/22/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
library std;
use std.textio.all; -- For basic I/O

entity tb_full_adder is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_full_adder;

architecture mixed of tb_full_adder is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- Define component interface.
    component full_adder is
        port (
            i_X    : in std_logic;
            i_Y    : in std_logic;
            i_Cin  : in std_logic;
            o_S    : out std_logic;
            o_Cout : out std_logic);
    end component;

    -- Input of tested module
    signal s_i_X, s_i_Y, s_i_Cin : std_logic := '0';

    -- Output signals of tested module
    signal s_o_S, s_o_Cout : std_logic;

begin

    -- instantiate full_adder component as DUT0 (Design Under Test)
    DUT0 : full_adder
    port map(
        i_X    => s_i_X,
        i_Y    => s_i_Y,
        i_Cin  => s_i_Cin,
        o_S    => s_o_S,
        o_Cout => s_o_Cout);

    --wait for 2 clock cycles to invert s_i_D0
    P_CONTROL_Cin : process
    begin
        wait for cCLK_PER * 2;
        s_i_Cin <= not s_i_Cin;
    end process;

    --wait for 4 clock cycles to invert s_i_D1
    P_CONTROL_Y : process
    begin
        wait for cCLK_PER * 4;
        s_i_Y <= not s_i_Y;
    end process;

    --wait for 8 clock cycles to invert s_i_S
    P_CONTROL_X : process
    begin
        wait for cCLK_PER * 8;
        s_i_X <= not s_i_X;
    end process;

end mixed;