-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the mux2t1 unit. The
-- testbench uses three different processes to alternate i_S, i_D0, and 
-- i_D1 at staggered times to recreate the truth table to verify all 
-- combinational options
-- 
-- Created 01/20/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
library std;
use std.textio.all; -- For basic I/O

entity tb_mux2t1 is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_mux2t1;

architecture mixed of tb_mux2t1 is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- We will be instantiating our design under test (DUT), so we need to specify its
    -- component interface.
    component mux2t1 is
        port (
            i_S  : in std_logic;
            i_D0 : in std_logic;
            i_D1 : in std_logic;
            o_O  : out std_logic);
    end component;

    -- Input and Output signals of tested module
    signal s_i_S : std_logic := '0';
    signal s_i_D0 : std_logic := '0';
    signal s_i_D1 : std_logic := '0';
    signal s_o_O : std_logic;
begin

    -- instantiate mux2t1 component as DUT0 (Design Under Test)
    DUT0 : mux2t1
    port map(
        i_S  => s_i_S,
        i_D0 => s_i_D0,
        i_D1 => s_i_D1,
        o_O  => s_o_O);

    --wait for 2 clock cycles to invert s_i_D0
    P_CONTROL_D0 : process
    begin
        wait for (gCLK_HPER * 2) * 2;
        s_i_D0 <= not s_i_D0;
    end process;

    --wait for 4 clock cycles to invert s_i_D1
    P_CONTROL_D1 : process
    begin
        wait for (gCLK_HPER * 2) * 4;
        s_i_D1 <= not s_i_D1;
    end process;

    --wait for 8 clock cycles to invert s_i_S
    P_CONTROL_S : process
    begin
        wait for (gCLK_HPER * 2) * 8;
        s_i_S <= not s_i_S;
    end process;

end mixed;