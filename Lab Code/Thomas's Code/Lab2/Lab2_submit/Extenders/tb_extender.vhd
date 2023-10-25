LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_extender IS
    GENERIC (gCLK_HPER : TIME := 10 ns);
END tb_extender;

ARCHITECTURE behavior OF tb_extender IS

    -- Calculate the clock period as twice the half-period
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT extender
        PORT (
            i_in : IN STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
            i_ctl : IN STD_LOGIC;
            o_ext : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0));
    END COMPONENT;

    SIGNAL s_in : STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
    Signal s_ctl : STD_LOGIC;
    SIGNAL s_ext : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
BEGIN
    extd : extender
    PORT MAP(
        i_in => s_in,
        i_ctl => s_ctl,
        o_ext => s_ext);

    P_TB : PROCESS
    BEGIN
        s_ctl <= '1';
        s_in <= STD_LOGIC_VECTOR(to_signed(0, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-1, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(81, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-256, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(17, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-512, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_ctl <= '0';
        s_in <= STD_LOGIC_VECTOR(to_signed(0, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-1, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(81, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-256, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(17, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
        s_in <= STD_LOGIC_VECTOR(to_signed(-512, s_in'length));
        WAIT FOR cCLK_PER * 2; -- for waveform clarity, I prefer not to change inputs on clk edges
    END PROCESS;

END behavior;