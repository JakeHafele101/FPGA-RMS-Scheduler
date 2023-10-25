LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_RippleCarryAdder IS
  GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_RippleCarryAdder;

ARCHITECTURE mixed OF tb_RippleCarryAdder IS

  -- Define the total clock period time
  CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
  CONSTANT bits : INTEGER := 32;

  -- We will be instantiating our design under test (DUT), so we need to specify its
  -- component interface.
  -- TODO: change component declaration as needed.
  COMPONENT RippleCarryAdder
    GENERIC (N : INTEGER := bits); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_Carry : IN STD_LOGIC;
      o_Carry : OUT STD_LOGIC;
      o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  SIGNAL s_D0 : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, bits));
  SIGNAL s_D1 : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, bits));
  SIGNAL s_inCarry : STD_LOGIC := '0';
  SIGNAL s_outCarry : STD_LOGIC;
  SIGNAL s_Sum : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0);

BEGIN

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : RippleCarryAdder
  PORT MAP(
    i_D0 => s_D0,
    i_D1 => s_D1,
    i_Carry => s_inCarry,
    o_Carry => s_outCarry,
    o_Sum => s_Sum);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  P_TEST : PROCESS
  BEGIN
    WAIT FOR cCLK_PER; 
    s_D0 <= STD_LOGIC_VECTOR(to_unsigned(5, s_D0'length));
    s_D1 <= STD_LOGIC_VECTOR(to_unsigned(7, s_D1'length));
    WAIT FOR cCLK_PER; 
    s_D0 <= STD_LOGIC_VECTOR(to_unsigned(25, s_D0'length));
    s_D1 <= STD_LOGIC_VECTOR(to_unsigned(37, s_D1'length));
    S_inCarry <='1';
    WAIT FOR cCLK_PER; 
    s_D0 <= X"FFFFFFFF";
    s_D1 <= X"00000001";
  END PROCESS;
END mixed;