-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- reg_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- register file using dffg.vhd for each bit 
--
--
-- 
-- Created 1/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_N is
  generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port (
    i_CLK : in std_logic;                          -- Clock input
    i_RST : in std_logic;                          -- Reset input
    i_WE  : in std_logic;                          -- Write enable input
    i_D   : in std_logic_vector(N - 1 downto 0);   --N bit data value input
    o_Q   : out std_logic_vector(N - 1 downto 0)); -- N bit data value output
end reg_N;

architecture structural of reg_N is

  component dffg is
    port (
      i_CLK : in std_logic;   -- Clock input
      i_RST : in std_logic;   -- Reset input
      i_WE  : in std_logic;   -- Write enable input
      i_D   : in std_logic;   -- Data value input
      o_Q   : out std_logic); -- Data value output
  end component;

  signal s_Q_old : std_logic_vector (N-1 downto 0);

begin

  -- Instantiate N mux instances.
  G_NBit_Reg : for i in 0 to N - 1 generate
    DFFI : dffg port map(
      i_CLK => i_CLK,   -- All instances share the same clock input
      i_RST => i_RST,   -- All instances share the same reset input
      i_WE  => i_WE,    -- All instances share the same write enable input
      i_D   => i_D(i),  -- ith instance's data input hooked up to ith data input.
      o_Q   => s_Q_old(i)); -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_Reg;

  with i_WE select 
    o_Q <= s_Q_old when '0',
           i_D when others;

end structural;