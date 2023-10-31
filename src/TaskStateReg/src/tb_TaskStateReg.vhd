LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

ENTITY tb_TaskStateReg IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_TaskStateReg;

ARCHITECTURE behavior OF tb_TaskStateReg IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT TaskStateReg
        generic (
	    INITIAL_PC: std_logic_vector(32 - 1 downto 0) := X"00000000";
        FINAL_PC: std_logic_vector(32 - 1 downto 0) := X"00000010");
        PORT (
        i_CLK        : in std_logic;
        i_Asynch_RST        : in std_logic;
        i_next_PC : in std_logic_vector(32 - 1 downto 0);
        i_next_PC_WE        : in std_logic;
        i_Period_Clear        : in std_logic;
        o_current_PC : out std_logic_vector(32 - 1 downto 0);
        o_isComplete     : out std_logic);
    END COMPONENT;

    SIGNAL s_CLK        :  std_logic;
    SIGNAL s_Asynch_RST        :  std_logic;
    SIGNAL s_next_PC :  std_logic_vector(32 - 1 downto 0);
    SIGNAL s_next_PC_WE        :  std_logic;
    SIGNAL s_Period_Clear        : std_logic;
    SIGNAL s_current_PC : std_logic_vector(32 - 1 downto 0);
    SIGNAL s_isComplete     : std_logic;
    

BEGIN
    DUT0 : TaskStateReg
    PORT MAP(
        i_CLK => s_CLK,
        i_Asynch_RST => s_Asynch_RST,
        i_next_PC => s_next_PC,
        i_next_PC_WE => s_next_PC_WE,
        i_Period_Clear => s_Period_Clear,
        o_current_PC => s_current_PC ,
        o_isComplete => s_isComplete);

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
        WAIT FOR cCLK_PER/4;
        s_Period_Clear<= '0';
        s_Asynch_RST <= '1';
        WAIT FOR cCLK_PER;
        s_Asynch_RST <= '0';
        s_next_PC_WE <= '0';
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(4, s_next_PC'length));
    
        WAIT FOR cCLK_PER;
        s_next_PC_WE <= '1';
        WAIT FOR cCLK_PER;
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(8, s_next_PC'length));
        WAIT FOR cCLK_PER;
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(12, s_next_PC'length));
        WAIT FOR cCLK_PER;
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(16, s_next_PC'length));
        WAIT FOR cCLK_PER;
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(20, s_next_PC'length));
        WAIT FOR cCLK_PER;
        s_next_PC_WE <= '0';
        WAIT FOR cCLK_PER;
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(13, s_next_PC'length));
        WAIT FOR cCLK_PER;
        s_Period_Clear<= '1';
        WAIT FOR cCLK_PER;
        s_Period_Clear<= '0';
        s_next_PC_WE <= '1';
        s_next_PC <= STD_LOGIC_VECTOR(to_unsigned(4, s_next_PC'length));
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        s_Asynch_RST <= '1';
        WAIT FOR cCLK_PER;

    END PROCESS;

END behavior;