------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 1 bit wide 2:1
-- mux using behavorial VHDL
--
--
-- 
-- Created 1/19/2023 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; --basic IEEE library

entity mux2t1_behav is

    port (
        i_S  : in std_logic;
        i_D0 : in std_logic;
        i_D1 : in std_logic;
        o_O  : out std_logic);

end mux2t1_behav;

-- "behavorial" is name of architecture "mux2t1_behav" is name of entity
architecture behavorial of mux2t1_behav is

begin
    process (i_S, i_D0, i_D1)
    begin
        o_O <= ((not i_S) and i_D0) or (i_S and i_D1);
    end process;

end behavorial;