LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.array32.ALL;

ENTITY Mux32t1 IS
  PORT (
    i_d : IN array32bits32;
    i_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END Mux32t1;

ARCHITECTURE rt1 OF Mux32t1 IS
BEGIN
  o_out <= i_d(to_integer(unsigned(i_sel)));
END rt1;