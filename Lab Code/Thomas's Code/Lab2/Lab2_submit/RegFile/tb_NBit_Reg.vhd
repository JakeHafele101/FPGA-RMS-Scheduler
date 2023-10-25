LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_NBit_Reg IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_NBit_Reg;

ARCHITECTURE behavior OF tb_NBit_Reg IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    CONSTANT bits : INTEGER := 32;

    COMPONENT NBit_Reg
        GENERIC (N : INTEGER := bits); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            i_CLK : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            i_WE : IN STD_LOGIC;
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT;

    -- Temporary signals to connect to the dff component.
    SIGNAL s_CLK, s_RST, s_WE : STD_LOGIC;
    SIGNAL s_D, s_Q : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0);

BEGIN

    DUT : NBit_Reg
    PORT MAP(
        i_CLK => s_CLK,
        i_RST => s_RST,
        i_WE => s_WE,
        i_D => s_D,
        o_Q => s_Q);

    -- This process sets the clock value (low for gCLK_HPER, then high
    -- for gCLK_HPER). Absent a "wait" command, processes restart 
    -- at the beginning once they have reached the final statement.
    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    -- Testbench process  
    P_TB : PROCESS
    BEGIN
        -- Reset the FF
        s_RST <= '1';
        s_WE <= '0';
        s_D <= STD_LOGIC_VECTOR(to_unsigned(0, s_D'length));
        WAIT FOR cCLK_PER;

        -- Store '68'
        s_RST <= '0';
        s_WE <= '1';
        s_D <= STD_LOGIC_VECTOR(to_unsigned(68, s_D'length));
        WAIT FOR cCLK_PER;

        -- Keep '68'
        s_RST <= '0';
        s_WE <= '0';
        s_D <= STD_LOGIC_VECTOR(to_unsigned(0, s_D'length));
        WAIT FOR cCLK_PER;

        -- Store '0'    
        s_RST <= '0';
        s_WE <= '1';
        s_D <= STD_LOGIC_VECTOR(to_unsigned(0, s_D'length));
        WAIT FOR cCLK_PER;

        -- Keep '0'
        s_RST <= '0';
        s_WE <= '0';
        s_D <= STD_LOGIC_VECTOR(to_unsigned(0, s_D'length));
        WAIT FOR cCLK_PER;

        -- Store '-844'    
        s_RST <= '0';
        s_WE <= '1';
        s_D <= STD_LOGIC_VECTOR(to_signed(-844, s_D'length));
        WAIT FOR cCLK_PER;
        -- Save'-844'    
        s_RST <= '0';
        s_WE <= '0';
        WAIT FOR cCLK_PER;
        -- Save '-844'    
        s_RST <= '0';
        s_WE <= '0';
        s_D <= STD_LOGIC_VECTOR(to_signed(37, s_D'length));
        WAIT FOR cCLK_PER;
        s_RST <= '1';
        WAIT FOR cCLK_PER;
        WAIT;
    END PROCESS;

END behavior;