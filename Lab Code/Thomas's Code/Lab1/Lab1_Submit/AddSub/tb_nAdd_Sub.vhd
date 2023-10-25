LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_nAdd_Sub IS
    GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_nAdd_Sub;

ARCHITECTURE mixed OF tb_nAdd_Sub IS

    -- Define the total clock period time
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    CONSTANT bits : INTEGER := 32;

    -- We will be instantiating our design under test (DUT), so we need to specify its
    -- component interface.
    -- TODO: change component declaration as needed.
    COMPONENT nAdd_Sub
        GENERIC (N : INTEGER := bits); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            nAdd_Sub : IN STD_LOGIC;
            o_Sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Carry : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL s_A : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, bits));
    SIGNAL s_B : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, bits));
    SIGNAL s_nAdd_Sub : STD_LOGIC := '0';
    SIGNAL s_outCarry : STD_LOGIC;
    SIGNAL s_Sum : STD_LOGIC_VECTOR(bits - 1 DOWNTO 0);

BEGIN

    -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
    -- input or output. Note that DUT0 is just the name of the instance that can be seen 
    -- during simulation. What follows DUT0 is the entity name that will be used to find
    -- the appropriate library component during simulation loading.
    DUT0 : nAdd_Sub
    PORT MAP(
        A => s_A,
        B => s_B,
        nAdd_Sub => s_nAdd_Sub,
        o_Carry => s_outCarry,
        o_Sum => s_Sum);
    --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
    P_TEST : PROCESS
    BEGIN
        WAIT FOR cCLK_PER;
    --Test Addition
        
        -- s_A <= STD_LOGIC_VECTOR(to_signed(-5, s_A'length));
        -- s_B <= STD_LOGIC_VECTOR(to_signed(-7, s_B'length));
        -- WAIT FOR cCLK_PER;
        -- s_A <= STD_LOGIC_VECTOR(to_signed(25, s_A'length));
        -- s_B <= STD_LOGIC_VECTOR(to_signed(37, s_B'length));
        -- WAIT FOR cCLK_PER;
        -- s_A <= X"FFFFFFFF";
        -- s_B <= X"00000001";
        -- WAIT FOR cCLK_PER;
        -- s_A <= STD_LOGIC_VECTOR(to_signed(-78, s_A'length));
        -- s_B <= STD_LOGIC_VECTOR(to_signed(59, s_B'length));
        -- WAIT FOR cCLK_PER;
        -- s_A <= STD_LOGIC_VECTOR(to_signed(-22, s_A'length));
        -- s_B <= STD_LOGIC_VECTOR(to_signed(47, s_B'length));
        -- WAIT FOR cCLK_PER;
    --Test Subtraction
        s_nAdd_Sub <= '1';
        s_A <= STD_LOGIC_VECTOR(to_signed(-15, s_A'length));
        s_B <= STD_LOGIC_VECTOR(to_signed(-19, s_B'length));
        WAIT FOR cCLK_PER;
        s_A <= STD_LOGIC_VECTOR(to_signed(105, s_A'length));
        s_B <= STD_LOGIC_VECTOR(to_signed(37, s_B'length));
        WAIT FOR cCLK_PER;
        s_A <= X"FFFFFFFF";
        s_B <= X"00000001";
        WAIT FOR cCLK_PER;
        s_A <= STD_LOGIC_VECTOR(to_signed(-78, s_A'length));
        s_B <= STD_LOGIC_VECTOR(to_signed(59, s_B'length));
        WAIT FOR cCLK_PER;
        s_A <= STD_LOGIC_VECTOR(to_signed(200, s_A'length));
        s_B <= STD_LOGIC_VECTOR(to_signed(217, s_B'length));
        WAIT FOR cCLK_PER;
    END PROCESS;
END mixed;