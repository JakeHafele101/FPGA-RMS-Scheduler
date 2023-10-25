LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY extender IS
  PORT (
    i_in : IN STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
    i_ctl : IN STD_LOGIC;
    o_ext : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
END extender;

ARCHITECTURE structural OF extender IS
BEGIN
    G_ExtendLOW : FOR i IN 0 TO 16 - 1 GENERATE
      o_ext(i) <= i_in(i);
    END GENERATE;
    G_ExtendHigh : FOR k IN 16 TO 32 - 1 GENERATE
        o_ext(k) <= i_in(15) when i_ctl = '1' else
          '0';
    END GENERATE;
END structural;