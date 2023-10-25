-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_adder_subber.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the adder_subber unit.
-- 
-- Created 01/23/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all; -- For logic types I/O
use IEEE.numeric_std.all;
library std;
use std.textio.all; -- For basic I/O

entity tb_adder_subber is
    generic (gCLK_HPER : time := 10 ns); -- Generic for half of the clock cycle period
end tb_adder_subber;

architecture mixed of tb_adder_subber is

    -- Define the total clock period time (20 * time unit)
    constant cCLK_PER : time := gCLK_HPER * 2;

    -- Define constant N for bits of operand inputs and output sum
    constant N : integer := 16;

    -- Define component interface.
    component adder_subber is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_A        : in std_logic_vector(N - 1 downto 0);
            i_B        : in std_logic_vector(N - 1 downto 0);
            i_nAdd_Sub : in std_logic;
            o_S        : out std_logic_vector(N - 1 downto 0);
            o_Cout     : out std_logic);
    end component;

    -- Input signals of tested module
    signal s_i_A, s_i_B : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal s_i_nAdd_Sub : std_logic := '0';

    -- Output signals of tested module
    signal s_o_S : std_logic_vector(N - 1 downto 0);
    signal s_o_Cout : std_logic;

    -- Internal test signals of testbench
    signal s_mismatch_S : std_logic;
    signal s_expected_S : integer;

begin

    -- instantiate adder_subber component as DUT0 (Design Under Test)
    DUT0 : adder_subber
    generic map(N => N)
    port map(
        i_A        => s_i_A,
        i_B        => s_i_B,
        i_nAdd_Sub => s_i_nAdd_Sub,
        o_S        => s_o_S,
        o_Cout     => s_o_Cout);

    P_MISMATCH : process (s_o_S)
    begin
        -- checks S mismatch
        if (s_expected_S /= to_integer(signed(s_o_S))) then --if add and not equal
            s_mismatch_S <= '1';
        else
            s_mismatch_S <= '0';
        end if;
    end process;

    -- Process to test adder_subber (DUT0)
    P_DUT0 : process
    begin
        --Adding test cases
        s_i_nAdd_Sub <= '0'; --add when 0

        s_i_A <= X"0000"; --decimal 0
        s_i_B <= X"0000"; --decimal 0
        s_expected_S <= 0; -- 0 + 0 = 0
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        s_i_A <= X"0001"; --decimal 1
        s_i_B <= X"0000"; --decimal 0
        s_expected_S <= 1; -- 1 + 0 = 1
        wait for cCLK_PER;

        s_i_A <= X"0000"; --decimal 0
        s_i_B <= X"0002"; --decimal 2
        s_expected_S <= 2; -- 0 + 2 = 2
        wait for cCLK_PER;

        s_i_A <= X"0017"; --decimal 23
        s_i_B <= X"0008"; --decimal 8
        s_expected_S <= 31; -- 23 + 8 = 31
        wait for cCLK_PER;

        s_i_A <= X"FFFF"; --decimal -1
        s_i_B <= X"FFFF"; --decimal -1
        s_expected_S <= - 2; -- -1 + (-1)
        wait for cCLK_PER;

        --Subtractor test cases
        s_i_nAdd_Sub <= '1'; --add when 0

        s_i_A <= X"0000"; --decimal 0
        s_i_B <= X"0000"; --decimal 0
        s_expected_S <= 0; -- 0 - 0 = 0
        wait for cCLK_PER; --wait for 1 clock period (20 ns)

        s_i_A <= X"0001"; --decimal 1
        s_i_B <= X"0000"; --decimal 0
        s_expected_S <= 1; -- 1 - 0 = 1
        wait for cCLK_PER;

        s_i_A <= X"0000"; --decimal 0
        s_i_B <= X"0002"; --decimal 2
        s_expected_S <= - 2; -- 0 - 2 = -2
        wait for cCLK_PER;

        s_i_A <= X"FFFF"; --decimal -1
        s_i_B <= X"FFFF"; --decimal -1
        s_expected_S <= 0; -- -1 - (-1) = 0
        wait for cCLK_PER;

        s_i_A <= X"0007"; --decimal 7
        s_i_B <= X"FFFC"; --decimal -4
        s_expected_S <= 11; -- 7 - (-4) = 11
        wait for cCLK_PER;

        wait;
    end process;

end mixed;