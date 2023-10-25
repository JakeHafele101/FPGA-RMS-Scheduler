LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

USE work.array32.ALL;

ENTITY tb_Mux32t1 IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_Mux32t1;

ARCHITECTURE behavior OF tb_Mux32t1 IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT Mux32t1
        PORT (
            i_d : IN array32bits32;
            i_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    -- Temporary signals to connect to the dff component.
    SIGNAL s_d : array32bits32;
    SIGNAL s_sel : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    SIGNAL s_out : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_Expected : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN
    DUT : Mux32t1
    PORT MAP(
        o_Out => s_Out,
        i_Sel => s_Sel,
        i_d => s_d);

    -- Testbench process  
    P_TB : PROCESS
    BEGIN
        WAIT FOR cCLK_PER;
        s_d(0) <= STD_LOGIC_VECTOR(to_unsigned(4, s_d(0)'length));
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(0, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(4, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_d(0) <= STD_LOGIC_VECTOR(to_unsigned(0, s_d(0)'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(0, s_Expected'length));
        s_d(1) <= STD_LOGIC_VECTOR(to_unsigned(32, s_d(0)'length));
        s_d(2) <= STD_LOGIC_VECTOR(to_unsigned(15, s_d(0)'length));
        s_d(6) <= STD_LOGIC_VECTOR(to_unsigned(97, s_d(0)'length));
        s_d(9) <= STD_LOGIC_VECTOR(to_unsigned(39, s_d(0)'length));
        s_d(16) <= STD_LOGIC_VECTOR(to_unsigned(100054, s_d(0)'length));
        s_d(25) <= STD_LOGIC_VECTOR(to_unsigned(1, s_d(0)'length));
        s_d(31) <= STD_LOGIC_VECTOR(to_unsigned(4, s_d(0)'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(2, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(15, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(6, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(97, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(31, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(4, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(25, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(1, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(0, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(0, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(2, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(15, s_Expected'length));
        WAIT FOR cCLK_PER;
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(16, s_Sel'length));
        s_Expected<= STD_LOGIC_VECTOR(to_unsigned(100054, s_Expected'length));

    END PROCESS;

END behavior;