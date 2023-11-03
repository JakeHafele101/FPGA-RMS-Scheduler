-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- program_counter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- DFF array that is intended to be used as a program counter. This is 
-- Updated from the DFF from our register file due to the PC needing to 
-- be reset to 0x0040 0000
-- 
-- Created 1/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity program_counter is
  port (
    i_CLK : in std_logic;                       -- Clock input
    i_RST : in std_logic;                       -- Reset input
    i_WE  : in std_logic;                       -- Write enable input
    i_D   : in std_logic_vector(31 downto 0);   --N bit data value input
    o_Q   : out std_logic_vector(31 downto 0)); -- N bit data value output
end program_counter;

architecture datapath of program_counter is

  signal s_D : std_logic_vector(31 downto 0); -- Multiplexed input to the FF
  signal s_Q : std_logic_vector(31 downto 0); -- Output of the FF

begin

  -- The output of the FF is fixed to s_Q
  o_Q <= s_Q;

  -- Create a multiplexed input to the FF based on i_WE
  with i_WE select
    s_D <= i_D when '1',
    s_Q when others; --aka 0

  -- on reset, set to 0x0040 0000 for start PC address
  process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      s_Q <= X"00400000";
    elsif (rising_edge(i_CLK)) then
      s_Q <= s_D;
    end if;
  end process;

  end datapath;