LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY FullAdder IS

  PORT (
    i_D0 : IN STD_LOGIC;
    i_D1 : IN STD_LOGIC;
    i_Carry : IN STD_LOGIC;
    o_Sum : OUT STD_LOGIC;
    o_Carry : OUT STD_LOGIC);

END FullAdder;

ARCHITECTURE structure OF FULLAdder IS

  -- Describe the component entities as defined in andg2.vhd, invg.vhd,
  -- org2.vhd.
  COMPONENT andg2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT xorg2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT org2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL s_A_B_XOR : STD_LOGIC;
  SIGNAL s_A_B_AND : STD_LOGIC;
  SIGNAL s_XOR_Cin : STD_LOGIC;

BEGIN

  ---------------------------------------------------------------------------
  -- Level 0: XOR and AND A and B
  ---------------------------------------------------------------------------

  g_XOR : xorg2
  PORT MAP(
    i_A => i_D0,
    i_B => i_D1,
    o_F => s_A_B_XOR);

  g_AND : andg2
  PORT MAP(
    i_A => i_D0,
    i_B => i_D1,
    o_F => s_A_B_AND);
  ---------------------------------------------------------------------------
  -- Level 1: And Signals with select or inverted select
  ---------------------------------------------------------------------------
  g_XORSUM : xorg2
  PORT MAP(
    i_A => s_A_B_XOR,
    i_B => i_Carry,
    o_F => o_Sum);

  g_AndXORCin : andg2
  PORT MAP(
    i_A => s_A_B_XOR,
    i_B => i_Carry,
    o_F => s_XOR_Cin);
  ---------------------------------------------------------------------------
  -- Level 2: Ors them together
  ---------------------------------------------------------------------------
  g_Or : org2
  PORT MAP(
    i_A => s_XOR_Cin,
    i_B => s_A_B_AND,
    o_F => o_Carry);

END structure;