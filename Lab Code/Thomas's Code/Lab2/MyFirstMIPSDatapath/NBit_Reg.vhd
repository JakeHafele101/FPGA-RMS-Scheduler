LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY NBit_Reg IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_CLK : IN STD_LOGIC;
    i_RST : IN STD_LOGIC;
    i_WE : IN STD_LOGIC;
    i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END NBit_Reg;

ARCHITECTURE structural OF NBit_Reg IS

  COMPONENT dffg IS
    PORT (
      i_CLK : IN STD_LOGIC; -- Clock input
      i_RST : IN STD_LOGIC; -- Reset input
      i_WE : IN STD_LOGIC; -- Write enable input
      i_D : IN STD_LOGIC; -- Data value input
      o_Q : OUT STD_LOGIC);
  END COMPONENT;

BEGIN

  -- Instantiate N Inverter instances.
  G_NBit_Reg : FOR i IN 0 TO N - 1 GENERATE
    REG : dffg PORT MAP(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE => i_WE,
      i_D => i_D(i),
      o_Q => o_Q(i));
  END GENERATE G_NBit_Reg;

END structural;