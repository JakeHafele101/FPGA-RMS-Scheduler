-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- array.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a std_logic_vector
-- array
--
-- 
-- Created 1/31/2023 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- package declaration
package arrays is 
    type word_array is array (natural range <>) of std_logic_vector(31 downto 0);
end package arrays;