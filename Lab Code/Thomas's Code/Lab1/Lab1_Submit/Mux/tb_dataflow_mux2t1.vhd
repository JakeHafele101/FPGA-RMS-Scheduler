library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_dataflow_mux2t1 is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_dataflow_mux2t1;

architecture mixed of tb_dataflow_mux2t1 is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component dataflow_mux2t1 is
  port(i_A                         : in std_logic;
  i_B                         : in std_logic;
  i_Sel                         : in std_logic;
  o_Out                         : out std_logic);
end component;

signal s_A   : std_logic := '0';
signal s_B   : std_logic := '0';
signal s_Sel : std_logic := '0';
signal s_Out   : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: dataflow_mux2t1
  port map(
            i_A       => s_A,
            i_B      => s_B,
            i_Sel     => s_Sel,
            o_Out       => s_Out);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html


  P_TEST_A: process
  begin
    wait for cCLK_PER*2; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_A <= not s_A;
  end process;

  P_TEST_B: process
  begin
    wait for cCLK_PER*4; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_B <= not s_B;
  end process;

  P_TEST_Sel: process
  begin
    wait for cCLK_PER*8; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_Sel <= not s_Sel;
  end process;

end mixed;