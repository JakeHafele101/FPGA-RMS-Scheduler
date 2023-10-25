-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_shift.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- shift module in our ALU
--
--
-- NOTES:
-- Created 3/7/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_shift is
    generic (gCLK_HPER : time := 2 ns);
end tb_shift;

architecture mixed of tb_shift is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component shift is
        port (
            i_shift_Sel : in std_logic_vector(1 downto 0);
            i_rt        : in std_logic_vector(31 downto 0);
            i_shamt     : in std_logic_vector(4 downto 0);
            o_result    : out std_logic_vector(31 downto 0));
    end component;

    -- Input signals of tested module
    signal i_shift_Sel : std_logic_vector (1 downto 0) := "00"; --10 shift Control bits
    signal i_rt : std_logic_vector (31 downto 0) := X"00000000"; --Input operand
    signal i_shamt : std_logic_vector(4 downto 0) := "00000"; -- shift amount for srl, sll

    -- Output signals of tested module
    signal o_result : std_logic_vector (31 downto 0);

    -- Test signals
    signal s_result_expected : std_logic_vector(31 downto 0);

    signal s_OP : integer;
    signal s_OP_ASCII : std_logic_vector(31 downto 0);

    signal s_rt_int, s_shamt_int : integer := 0;
    signal s_shift : integer;

    signal s_result_error : std_logic := '0';

begin

    DUT0 : shift
    port map(
        i_shift_Sel => i_shift_Sel,
        i_rt        => i_rt,
        i_shamt     => i_shamt,
        o_result    => o_result
    );

    i_rt <= std_logic_vector(to_signed(s_rt_int, i_rt'length));
    i_shamt <= std_logic_vector(to_signed(s_shamt_int, i_shamt'length));

    P_RESULT_CHK : process
    begin

        wait for gCLK_HPER;

        if (s_result_expected /= o_result) then
            s_result_error <= '1';
        else
            s_result_error <= '0';
        end if;
    end process;

    P_OP : process (s_OP, i_rt, i_shamt) is
    begin

        if (s_OP = 9) then --sll
            i_shift_Sel <= "00";
            s_result_expected <= std_logic_vector(to_signed(s_shift, s_result_expected'length));
            s_OP_ASCII <= X"534C4C20"; --SLL

        elsif (s_OP = 10) then --srl
            i_shift_Sel <= "01";
            s_result_expected <= std_logic_vector(to_signed(s_shift, s_result_expected'length));
            s_OP_ASCII <= X"53524C20"; --SRL

        elsif (s_OP = 11) then --sra
            i_shift_Sel <= "11";
            s_result_expected <= std_logic_vector(to_signed(s_shift, s_result_expected'length));
            s_OP_ASCII <= X"53524120"; --SRA

        elsif (s_OP = 12) then --lui, shift left 16
            i_shift_Sel <= "10";
            s_result_expected <= std_logic_vector(to_signed(s_shift, s_result_expected'length));
            s_OP_ASCII <= X"4C554920"; --LUI

        end if;
    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- SHIFT -- 

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 0;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 1;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 2;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 4;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 8;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 0;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 1;
        s_shift <= -2; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 2;
        s_shift <= -4; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 4;
        s_shift <= -16; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 8;
        s_shift <= 	-256; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 16;
        s_shift <= -65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= -1;
        s_shamt_int <= 31;
        s_shift <= -2147483648; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 284675;
        s_shamt_int <= 6;
        s_shift <= 18219200; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 461805;
        s_shamt_int <= 19;
        s_shift <= 1600651264; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 1;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 2;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 4;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 8;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 0;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 1;
        s_shift <= 2147483647; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 2;
        s_shift <= 1073741823; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 4;
        s_shift <= 268435455; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 8;
        s_shift <= 	16777215; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -1;
        s_shamt_int <= 16;
        s_shift <= 65535; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= -19837;
        s_shamt_int <= 17;
        s_shift <= 32767; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 461805;
        s_shamt_int <= 9;
        s_shift <= 901; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 1;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 2;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 4;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 8;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 0;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 1;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 2;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 4;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 8;
        s_shift <= 	-1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 16;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -1;
        s_shamt_int <= 31;
        s_shift <= -1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 284675;
        s_shamt_int <= 6;
        s_shift <= 4448; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 1957309;
        s_shamt_int <= 12;
        s_shift <= - 478; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= -2147483648;
        s_shamt_int <= 1;
        s_shift <= -1073741824; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 2147483648;
        s_shamt_int <= 8;
        s_shift <= - 8388608; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 2147483648;
        s_shamt_int <= 16;
        s_shift <= - 32768; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 2147483648;
        s_shamt_int <= 31;
        s_shift <= - 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= 0;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= -1;
        s_shift <= -65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= 65535;
        s_shift <= -65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= 1738;
        s_shift <= 113901568; --expected shift output
        wait for cCLK_PER;

        wait;
    end process;

end mixed;