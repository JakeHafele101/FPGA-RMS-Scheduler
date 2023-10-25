-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ripple_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the ripple_adder unit.
-- The testbench uses three different processes to alternate i_X, i_Y, 
-- and i_Cin at staggered times to recreate the truth table to verify all 
-- combinational options
-- 
-- Created 01/22/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
use IEEE.numeric_std.all;
library std;
use std.textio.all; -- For basic I/O

entity tb_ripple_adder is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_ripple_adder;

architecture mixed of tb_ripple_adder is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- Define constant N for bits of operand inputs and output sum
    constant N : integer := 16;

    -- Define component interface.
    component ripple_adder is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_X    : in std_logic_vector(N - 1 downto 0);
            i_Y    : in std_logic_vector(N - 1 downto 0);
            i_Cin  : in std_logic;
            o_S    : out std_logic_vector(N - 1 downto 0);
            o_Cout : out std_logic);
    end component;

    -- Input signals of tested module
    signal s_i_X, s_i_Y : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal s_i_Cin : std_logic := '0';

    -- Output signals of tested module
    signal s_o_S : std_logic_vector(N - 1 downto 0);
    signal s_o_Cout : std_logic;

    --Testbench signals
    signal s_mismatch_S : std_logic := '0';
    signal s_expected_S : integer;

begin

    -- instantiate ripple_adder component as DUT0 (Design Under Test)
    DUT0 : ripple_adder
    generic map(N => N)
    port map(
        i_X    => s_i_X,
        i_Y    => s_i_Y,
        i_Cin  => s_i_Cin,
        o_S    => s_o_S,
        o_Cout => s_o_Cout);

    P_MISMATCH : process (s_o_S)
    begin
        -- checks S mismatch
        if (s_expected_S /= to_integer(signed(s_o_S))) then --if add and not equal
            s_mismatch_S <= '1';
        else
            s_mismatch_S <= '0';
        end if;
    end process;

    -- Process to test ripple_adder (DUT0)
    P_DUT0 : process
    begin
        --Add all zero's
        s_i_X <= X"0000";
        s_i_Y <= X"0000";
        s_i_Cin <= '0';
        s_expected_S <= 0;
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --Only add with s_i_Cin
        s_i_X <= X"0000";
        s_i_Y <= X"0000";
        s_i_Cin <= '1';
        s_expected_S <= 1;
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --Only add with s_i_X
        s_i_X <= X"0002";
        s_i_Y <= X"0000";
        s_i_Cin <= '0';
        s_expected_S <= 2;
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --Only add with s_i_Y
        s_i_X <= X"0000";
        s_i_Y <= X"0003";
        s_i_Cin <= '0';
        s_expected_S <= 3;
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --Add max values
        s_i_X <= X"0000"; -- 0
        s_i_Y <= X"FFFF"; -- -1
        s_i_Cin <= '1'; -- +1
        s_expected_S <= 0; -- 0
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --Add max values without carry in
        s_i_X <= X"0000"; -- 0
        s_i_Y <= X"8000"; -- -32768
        s_i_Cin <= '0';
        s_expected_S <= - 32768; -- -32768
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --TPU Case 1
        s_i_X <= X"0005"; --decimal 5
        s_i_Y <= X"0019"; --decimal 25
        s_i_Cin <= '1';
        s_expected_S <= 31; -- 31
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --TPU Case 2
        s_i_X <= X"0019"; --decimal 25
        s_i_Y <= X"0005"; --decimal 5
        s_i_Cin <= '0';
        s_expected_S <= 30; --30
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        --TPU Case 3, birthday
        s_i_X <= X"0001"; --decimal 1
        s_i_Y <= X"0003"; --decimal 3
        s_i_Cin <= '1';
        s_expected_S <= 5;
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        wait;
    end process;

end mixed;