LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_dmem IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_dmem;

ARCHITECTURE behavior OF tb_dmem IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    CONSTANT bits : INTEGER := 32;
    CONSTANT add : INTEGER := 10;

    COMPONENT mem
        GENERIC (
            DATA_WIDTH : NATURAL := 32;
            ADDR_WIDTH : NATURAL := 10
        );
        PORT (
            clk : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
            data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
            we : IN STD_LOGIC := '1';
            q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
    END COMPONENT;

    SIGNAL s_CLK, s_WE : STD_LOGIC := '0';
    SIGNAL s_addr : STD_LOGIC_VECTOR(add - 1 DOWNTO 0);
    SIGNAL s_data : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0);
    SIGNAL s_q : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0);

BEGIN
    dmem : mem
    PORT MAP(
        CLK => s_CLK,
        addr => s_addr,
        WE => s_WE,
        data => s_data,
        q => s_Q);

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
        s_data <= x"00000000";
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(0, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(1, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(2, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(3, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(4, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(5, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(6, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(7, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(8, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(9, s_addr'length));
        WAIT FOR cCLK_PER;

        s_WE <= '1';
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(256, s_addr'length));
        s_data <= x"FFFFFFFF";
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(257, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_unsigned(2, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(258, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(-3, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(259, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(4, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(260, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(5, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(261, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(6, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(262, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(-7, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(263, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(-8, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(264, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(9, s_data'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(265, s_addr'length));
        s_data <= STD_LOGIC_VECTOR(to_signed(-10, s_data'length));
        WAIT FOR cCLK_PER;

        s_WE <= '0';
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(256, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(257, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(258, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(259, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(260, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(261, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(262, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(263, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(264, s_addr'length));
        WAIT FOR cCLK_PER;
        s_addr <= STD_LOGIC_VECTOR(to_unsigned(265, s_addr'length));
        WAIT FOR cCLK_PER;
    END PROCESS;

END behavior;
