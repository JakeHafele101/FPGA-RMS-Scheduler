-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using dataflow VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1_N is
  generic (N : integer := 16); -- Generic of type integer for input/output data width. Default value is 16.
  port (
    i_S  : in std_logic;
    i_D0 : in std_logic_vector(N - 1 downto 0);
    i_D1 : in std_logic_vector(N - 1 downto 0);
    o_O  : out std_logic_vector(N - 1 downto 0));
end mux2t1_N;

architecture dataflow of mux2t1_N is

  component mux2t1 is
    port (
      i_S  : in std_logic;
      i_D0 : in std_logic;
      i_D1 : in std_logic;
      o_O  : out std_logic);
  end component;

begin

  process (i_S, i_D0, i_D1)
  begin
    if(i_S = '0') then
      o_O <= i_D0;
    else
      o_O <= i_D1;
    end if;

  end process;

end dataflow;