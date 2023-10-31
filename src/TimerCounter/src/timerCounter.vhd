-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- timerCounter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N bit 
--              synchronous counter
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity timerCounter is

  generic (N : integer := 32;
           LCM : std_logic_vector(31 downto 0) := X"0000000F"); -- Set to 1 less than LCM
  port (
    i_CLK : in std_logic;   -- Clock input
    i_RST : in std_logic;   -- Reset input
    i_WE  : in std_logic;   -- Write enable input
    o_count   : out std_logic_vector(N-1 downto 0);
    o_LCMclear : out std_logic); -- Data value output

end timerCounter;

architecture mixed of timerCounter is

  component ripple_adder is
    generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port (
        i_X    : in std_logic_vector(N - 1 downto 0);
        i_Y    : in std_logic_vector(N - 1 downto 0);
        i_Cin  : in std_logic;
        o_S    : out std_logic_vector(N - 1 downto 0);
        o_Cout : out std_logic);
  end component;

  signal s_count : std_logic_vector(N-1 downto 0); -- Multiplexed input to the FF
  signal s_add   : std_logic_vector(N-1 downto 0);
    
begin

  process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      s_count <= (others => '0'); 
    elsif (rising_edge(i_CLK)) then
      
      if(i_WE = '1') then
        if(s_count < LCM) then
          s_count <= s_add;
        else 
          s_count <= (others => '0');
        end if;
      else
        s_count <= s_count;
      end if;

    end if;

  end process;

  o_count <= s_count;

  process (s_count)
  begin
      
    if(s_count >= LCM) then
      o_LCMclear <= '1';
    else
      o_LCMclear <= '0';
    end if;

  end process;

  RIPPLE_ADD : ripple_adder
  generic map(N => N)
  port map(
      i_X    => s_count,
      i_Y    => X"00000001",
      i_Cin  => '0',
      o_S    => s_add,
      o_Cout => open);

end mixed;