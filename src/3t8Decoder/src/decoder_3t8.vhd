-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- decoder_3t8.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 5-32 decoder
--
--
-- 
-- Created 1/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity decoder_3t8 is
  port (
    i_A   : in std_logic_vector(2 downto 0);    --5 bit data value input
    i_WE  : in std_logic; 
    o_F   : out std_logic_vector(7 downto 0)); -- 32 bit data value output
end decoder_3t8;

architecture dataflow of decoder_3t8 is

  signal s_Sel : std_logic_vector(3 downto 0);
begin

  s_Sel <= i_A & i_WE;

  with (s_Sel) select
      o_F <= "00000001" when "0001", 
             "00000010" when "0011", 
             "00000100" when "0101",
             "00001000" when "0111", 
             "00010000" when "1001",
             "00100000" when "1011", 
             "01000000" when "1101",
             "10000000" when "1111",
             "00000000" when others;
end dataflow;