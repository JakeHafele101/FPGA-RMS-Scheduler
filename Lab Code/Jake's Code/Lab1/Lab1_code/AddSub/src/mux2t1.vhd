-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 1 bit wide 2:1
-- mux using structural VHDL
--
--
-- 
-- Created 1/19/2023 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
entity mux2t1 is

  port (
    i_S  : in std_logic;
    i_D0 : in std_logic;
    i_D1 : in std_logic;
    o_O  : out std_logic);

end mux2t1;

architecture structural of mux2t1 is

  -- not gate component description
  component invg is
    port (
      i_A : in std_logic;
      o_F : out std_logic);
  end component;

  --2 input and gate
  component andg2 is
    port (
      i_A : in std_logic;
      i_B : in std_logic;
      o_F : out std_logic);
  end component;

  --2 input or gate
  component org2 is
    port (
      i_A : in std_logic;
      i_B : in std_logic;
      o_F : out std_logic);
  end component;

  --intermediate signal declaration would go here!
  signal s_inv_S, s_and_D0, s_and_D1 : std_logic;

begin

  --invert select input i_S
  g_inv_1 : invg
  port map(
    i_A => i_S,
    o_F => s_inv_S);

  -- AND together ~s_inv_S and i_D0
  g_and2_1 : andg2
  port map(
    i_A => s_inv_S,
    i_B => i_D0,
    o_F => s_and_D0);

  -- AND together i_S and i_D1
  g_and2_2 : andg2
  port map(
    i_A => i_S,
    i_B => i_D1,
    o_F => s_and_D1);
  -- OR together s_and_D0 and s_and_D1 to output o_O
  g_or2_1 : org2
  port map(
    i_A => s_and_D0,
    i_B => s_and_D1,
    o_F => o_O);

end structural;