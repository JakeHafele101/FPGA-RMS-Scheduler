library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_FullAdder is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_FullAdder;

architecture mixed of tb_FullAdder is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component FullAdder is
  port(i_D0                         : in std_logic;
  i_D1                         : in std_logic;
  i_Carry                         : in std_logic;
  o_Sum                         : out std_logic;
  o_Carry                         : out std_logic);
end component;

signal s_A   : std_logic := '0';
signal s_B   : std_logic := '0';
signal s_Cin : std_logic := '0';
signal s_Sout  : std_logic;
signal s_Cout   : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: FullAdder
  port map(
            i_D0       => s_A,
            i_D1      => s_B,
            i_Carry     => s_Cin,
            o_Sum       =>s_Sout,
            o_Carry     =>s_Cout);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html


  P_TEST_A: process
  begin
    wait for cCLK_PER; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_A <= not s_A;
  end process;

  P_TEST_B: process
  begin
    wait for cCLK_PER*2; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_B <= not s_B;
  end process;

  P_TEST_Cin: process
  begin
    wait for cCLK_PER*4; -- for waveform clarity, I prefer not to change inputs on clk edges
    s_Cin <= not s_Cin;
  end process;

end mixed;