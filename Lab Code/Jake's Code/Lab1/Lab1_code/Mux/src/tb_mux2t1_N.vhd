-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the mux2t1_N unit. The 
-- mux2t1_N unit uses a generic (default 16) integer value to create N 
-- 2 to 1 MUX's from the mux2t1 module. This means I will need N i_D0 and 
-- i_D1 bits for the inputs, one select line bit, and N o_O bits
-- 
-- Created 01/20/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
use IEEE.numeric_std.all; -- for std_logic_vector to integer conversion
library std;
use std.textio.all; -- For basic I/O

entity tb_mux2t1_N is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_mux2t1_N;

architecture mixed of tb_mux2t1_N is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- define N integer constant for each DUT
    constant N0 : integer := 4;
    constant N1 : integer := 8;
    constant N2 : integer := 16;

    --set component interface of DUT
    component mux2t1_N is
        generic (N : integer := 16); -- Generic of type integer for input/output data width. Default value is 16.
        port (
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(N - 1 downto 0);
            i_D1 : in std_logic_vector(N - 1 downto 0);
            o_O  : out std_logic_vector(N - 1 downto 0));
    end component;

    -- Input signals of tested modules
    signal s_i_S : std_logic := '0'; --select line of mux2t1_n
    signal s_i_D0 : std_logic_vector((N2 - 1) downto 0) := (others => '0'); --"others => '0'" sets all bits in vector to 0!
    signal s_i_D1 : std_logic_vector((N2 - 1) downto 0) := (others => '0');

    --Output signals of tested modules
    signal s_o_O_DUT0 : std_logic_vector((N0 - 1) downto 0);
    signal s_o_O_DUT1 : std_logic_vector((N1 - 1) downto 0);
    signal s_o_O_DUT2 : std_logic_vector((N2 - 1) downto 0);
    
    -- Testbench signals 
    signal s_DUT_select : integer := 0; --selects which DUT to test in order
begin

    -- mux2t1_N with 4 mu2t1 modules
    DUT0 : mux2t1_N
    generic map(N => N0) 
    port map(
        i_S  => s_i_S,
        i_D0 => s_i_D0((N0 - 1) downto 0),
        i_D1 => s_i_D1((N0 - 1) downto 0),
        o_O  => s_o_O_DUT0);

    -- mux2t1_N with 8 mu2t1 modules
    DUT1 : mux2t1_N
    generic map(N => N1) 
    port map(
        i_S  => s_i_S,
        i_D0 => s_i_D0((N1 - 1) downto 0),
        i_D1 => s_i_D1((N1 - 1) downto 0),
        o_O  => s_o_O_DUT1);

    -- mux2t1_N with 16 mu2t1 modules
    DUT2 : mux2t1_N
    generic map(N => N2) 
    port map(
        i_S  => s_i_S,
        i_D0 => s_i_D0((N2 - 1) downto 0),
        i_D1 => s_i_D1((N2 - 1) downto 0),
        o_O  => s_o_O_DUT2);

    --process to test DUT0 with 4 mux2t1 Modules (0 to 15 decimal)
    P_DUT : process
    begin
        if (s_DUT_select = 0) then --DUT0 testing (0 to 15)
            s_i_S <= '0';
            s_i_D0 <= 16D"0"; 
            s_i_D1 <= 16D"10";
            wait for cCLK_PER; 

            s_i_S <= '1';
            wait for cCLK_PER;

            s_i_S <= '0';
            s_i_D0 <= 16D"1"; 
            wait for cCLK_PER; 

            s_i_D0 <= 16D"2"; 
            wait for cCLK_PER;

            s_i_S <= '1';
            s_i_D1 <= 16D"11"; 
            wait for cCLK_PER; 

            s_i_D1 <= 16D"12"; 
            wait for cCLK_PER;

        elsif (s_DUT_select = 1) then --DUT1 testing (0 to 255)
            
            s_i_S <= '0';
            s_i_D0 <= 16D"100"; 
            s_i_D1 <= 16D"200";
            wait for cCLK_PER; 

            s_i_S <= '1';
            wait for cCLK_PER;

            s_i_S <= '0';
            s_i_D0 <= 16D"101"; 
            wait for cCLK_PER; 

            s_i_D0 <= 16D"102"; 
            wait for cCLK_PER;

            s_i_S <= '1';
            s_i_D1 <= 16D"201"; 
            wait for cCLK_PER; 

            s_i_D1 <= 16D"202"; 
            wait for cCLK_PER;

        elsif (s_DUT_select = 2) then 

            s_i_S <= '0';
            s_i_D0 <= 16D"1000"; 
            s_i_D1 <= 16D"2000";
            wait for cCLK_PER; 

            s_i_S <= '1';
            wait for cCLK_PER;

            s_i_S <= '0';
            s_i_D0 <= 16D"1001"; 
            wait for cCLK_PER; 

            s_i_D0 <= 16D"1002"; 
            wait for cCLK_PER;

            s_i_S <= '1';
            s_i_D1 <= 16D"2001"; 
            wait for cCLK_PER; 

            s_i_D1 <= 16D"2002"; 
            wait for cCLK_PER;

            wait;
        end if;
        
        s_DUT_select <= s_DUT_select + 1;
        wait for cCLK_PER;

    end process;

end mixed;