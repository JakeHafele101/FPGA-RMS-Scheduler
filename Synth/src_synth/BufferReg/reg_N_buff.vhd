-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- reg_N_buff.vhd
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

entity reg_N_buff is
  generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port (
    i_CLK   : in std_logic;                          -- Clock input
    i_RST   : in std_logic;                          -- Reset input
    i_WE    : in std_logic;                          -- Write enable input
    i_D     : in std_logic_vector(N - 1 downto 0);   -- N bit data value input
    i_stall : in std_logic;                          -- If stall is 0, write to reg
    i_flush : in std_logic;                          -- If flush is 1, write 0's to reg
    o_Q     : out std_logic_vector(N - 1 downto 0)); -- N bit data value output
end reg_N_buff;

architecture structural of reg_N_buff is

  component dffg is
    port (
      i_CLK : in std_logic;   -- C lock input
      i_RST : in std_logic;   -- Reset input
      i_WE  : in std_logic;   -- Write enable input
      i_D   : in std_logic;   -- Data value input
      o_Q   : out std_logic); -- Data value output
  end component;

  signal s_D_MUX : std_logic_vector(N - 1 downto 0);
  signal s_zeros : std_logic_vector(N - 1 downto 0);
  signal s_nStall : std_logic;

begin

  s_nStall <= not i_stall;
  s_zeros <= (others => '0');

  with i_flush select
    s_D_MUX <= i_D when '0',
    s_zeros when others;

  -- Instantiate N mux instances.
  G_NBit_Reg : for i in 0 to N - 1 generate
    DFFI : dffg port map(
      i_CLK => i_CLK,      -- All instances share the same clock input
      i_RST => i_RST,      -- All instances share the same reset input
      i_WE  => s_nStall,       -- All instances share the same write enable input
      i_D   => s_D_MUX(i), -- ith instance's data input hooked up to ith data input.
      o_Q   => o_Q(i));    -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_Reg;
end structural;