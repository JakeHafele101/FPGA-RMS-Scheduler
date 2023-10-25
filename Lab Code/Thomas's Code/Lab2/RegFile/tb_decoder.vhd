LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_decoder IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_decoder;

ARCHITECTURE behavior OF tb_decoder IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT decoder
        PORT (
            i_Sel : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
            i_write : IN STD_LOGIC;
            o_O : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
    END COMPONENT;

    -- Temporary signals to connect to the dff component.
    SIGNAL s_Sel : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    SIGNAL s_O : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL s_write : STD_LOGIC;

BEGIN

    DUT : decoder
    PORT MAP(
        i_Sel => s_Sel,
        o_O => s_O,
        i_write => s_write);

    -- Testbench process  
    P_TB : PROCESS
    BEGIN
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(0, s_Sel'length));
        s_write <='1';
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(1, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(2, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(3, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(4, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(5, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(6, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(7, s_Sel'length));
        WAIT FOR cCLK_PER;

        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(30, s_Sel'length));
        s_write <='0';
        WAIT FOR cCLK_PER;
        s_write <='1';
        s_Sel <= STD_LOGIC_VECTOR(to_unsigned(31, s_Sel'length));
        WAIT FOR cCLK_PER;

    END PROCESS;

END behavior;