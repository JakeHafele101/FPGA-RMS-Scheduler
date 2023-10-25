library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
use ieee.numeric_std.all;
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_mux2t1_N is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_mux2t1_N;

architecture mixed of tb_mux2t1_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant bits : integer := 8;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component mux2t1_N
    generic(N : integer := bits); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

signal s_D0   : std_logic_vector(bits-1 downto 0) := std_logic_vector(to_unsigned(0, bits));
signal s_D1   : std_logic_vector(bits-1 downto 0) := std_logic_vector(to_unsigned(0, bits));
signal s_S : std_logic := '0';
signal s_O   : std_logic_vector(bits-1 downto 0);

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: mux2t1_N
  port map(
            i_D0       => s_D0,
            i_D1      => s_D1,
            i_S     => s_S,
            o_O       => s_O);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html


  P_TEST: process
  begin
    wait for cCLK_PER*2; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_D0 <= std_logic_vector(to_unsigned(128, s_D0'length));
    s_D1 <= std_logic_vector(to_unsigned(400, s_D1'length));
    s_S <= '0';
    wait for cCLK_PER*2;
    s_S <= '1';
    wait for cCLK_PER*2;
    s_D0 <= std_logic_vector(to_unsigned(1, s_D0'length));
    s_D1 <= std_logic_vector(to_unsigned(4, s_D1'length));
    wait for cCLK_PER*2;
    s_S <= '0';
    wait for cCLK_PER*2;
    s_D0 <= std_logic_vector(to_unsigned(65535, s_D0'length));
    s_D1 <= std_logic_vector(to_unsigned(0, s_D1'length));
    wait for cCLK_PER*2;
    s_S <= '1';
  end process;
end mixed;