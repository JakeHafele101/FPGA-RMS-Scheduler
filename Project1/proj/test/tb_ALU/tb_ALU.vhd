-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level ALU file in our Single Cycle MIPS Processor
--
--
-- NOTES:
-- Created 2/26/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ALU is
    generic (gCLK_HPER : time := 2 ns);
end tb_ALU;

architecture mixed of tb_ALU is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component ALU is
        port (
            i_nAdd_Sub   : in std_logic;
            i_shift_Sel  : in std_logic_vector(1 downto 0);
            i_branch_Sel : in std_logic_vector(2 downto 0);
            i_logic_Sel  : in std_logic_vector(1 downto 0);
            i_out_Sel    : in std_logic_vector(1 downto 0);
            i_rs         : in std_logic_vector(31 downto 0);
            i_rt         : in std_logic_vector(31 downto 0);
            i_shamt      : in std_logic_vector(4 downto 0);
            o_branch     : out std_logic;
            o_overflow   : out std_logic;
            o_rd         : out std_logic_vector(31 downto 0));
    end component;

    -- Input signals of tested module
    signal i_ALU_CTRL : std_logic_vector (9 downto 0) := "0000000000"; --10 ALU Control bits
    signal i_rs, i_rt : std_logic_vector (31 downto 0) := X"00000000"; --Input operands
    signal i_shamt : std_logic_vector(4 downto 0) := "00000"; -- shift amount for srl, sll

    -- Output signals of tested module
    signal o_branch, o_overflow : std_logic;
    signal o_rd : std_logic_vector (31 downto 0);

    -- Test signals
    signal s_branch_chk, s_overflow_chk, s_rd_chk : std_logic := '0';
    signal s_branch_expected, s_overflow_expected : std_logic := '0';
    signal s_rd_expected : std_logic_vector(31 downto 0);

    signal s_OP : integer;
    signal s_OP_ASCII : std_logic_vector(31 downto 0);

    signal s_rs_int, s_rt_int, s_shamt_int : integer := 0;
    signal s_add, s_sub, s_shift : integer;
    signal s_less : std_logic_vector(31 downto 0);

    signal s_branch_error, s_overflow_error : std_logic := '0';
    signal s_rd_error : std_logic := '0';

begin

    DUT0 : ALU
    port map(
        i_nAdd_Sub   => i_ALU_CTRL(9),
        i_shift_Sel  => i_ALU_CTRL(8 downto 7),
        i_branch_Sel => i_ALU_CTRL(6 downto 4),
        i_logic_Sel  => i_ALU_CTRL(3 downto 2),
        i_out_Sel    => i_ALU_CTRL(1 downto 0),
        i_rs         => i_rs,
        i_rt         => i_rt,
        i_shamt      => i_shamt,
        o_branch     => o_branch,
        o_overflow   => o_overflow,
        o_rd         => o_rd
    );

    i_rs <= std_logic_vector(to_signed(s_rs_int, i_rs'length));
    i_rt <= std_logic_vector(to_signed(s_rt_int, i_rt'length));
    i_shamt <= std_logic_vector(to_signed(s_shamt_int, i_shamt'length));

    s_add <= s_rs_int + s_rt_int;
    s_sub <= s_rs_int - s_rt_int;

    P_BRANCH_CHK : process
    begin

        wait for gCLK_HPER;

        if ((s_branch_chk and (s_branch_expected xor o_branch)) = '1') then
            s_branch_error <= '1';
        else
            s_branch_error <= '0';
        end if;
    end process;

    P_OVERFLOW_CHK : process 
    begin

        wait for gCLK_HPER;

        if ((s_overflow_chk and (s_overflow_expected xor o_overflow)) = '1') then
            s_overflow_error <= '1';
        else
            s_overflow_error <= '0';
        end if;
    end process;

    P_RD_CHK : process
    begin

        wait for gCLK_HPER;

        if ((s_rd_chk = '1') and (s_rd_expected /= o_rd)) then
            s_rd_error <= '1';
        else
            s_rd_error <= '0';
        end if;
    end process;

    P_LESS : process (s_OP, s_rs_int, s_rt_int) is
    begin

        if (s_rs_int < s_rt_int) then
            s_less <= X"00000001";
        else
            s_less <= X"00000000";
        end if;

    end process;

    P_OP : process (s_OP, i_rs, i_rt, i_shamt) is
    begin

        if (s_OP = 0) then --add
            i_ALU_CTRL <= "0000000000";
            s_overflow_chk <= '1';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_add, s_rd_expected'length));
            s_OP_ASCII <= X"41444420"; -- ADD

        elsif (s_OP = 1) then --add unsigned
            i_ALU_CTRL <= "0000000000";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_add, s_rd_expected'length));
            s_OP_ASCII <= X"41444455"; -- ADDU

        elsif (s_OP = 2) then --sub
            i_ALU_CTRL <= "1000000000";
            s_overflow_chk <= '1';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_sub, s_rd_expected'length));
            s_OP_ASCII <= X"53554220"; --SUB

        elsif (s_OP = 3) then --sub unsigned
            i_ALU_CTRL <= "1000000000";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_sub, s_rd_expected'length));
            s_OP_ASCII <= X"53554255"; --SUBU

        elsif (s_OP = 4) then --and
            i_ALU_CTRL <= "0000000010";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= i_rs and i_rt;
            s_OP_ASCII <= X"414E4420"; --AND

        elsif (s_OP = 5) then --nor
            i_ALU_CTRL <= "0000000110";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= i_rs nor i_rt;
            s_OP_ASCII <= X"4E4F5220"; --NOR

        elsif (s_OP = 6) then --xor
            i_ALU_CTRL <= "0000001010";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= i_rs xor i_rt;
            s_OP_ASCII <= X"584F5220"; --XOR

        elsif (s_OP = 7) then --or
            i_ALU_CTRL <= "0000001110";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= i_rs or i_rt;
            s_OP_ASCII <= X"4F522020"; --OR

        elsif (s_OP = 8) then --slt
            i_ALU_CTRL <= "1000000011";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= s_less;
            s_OP_ASCII <= X"534C5420"; --SLT

        elsif (s_OP = 9) then --sll
            i_ALU_CTRL <= "0000000001";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_shift, s_rd_expected'length));
            s_OP_ASCII <= X"534C4C20"; --SLL

        elsif (s_OP = 10) then --srl
            i_ALU_CTRL <= "0010000001";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_shift, s_rd_expected'length));
            s_OP_ASCII <= X"53524C20"; --SRL

        elsif (s_OP = 11) then --sra
            i_ALU_CTRL <= "0110000001";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_shift, s_rd_expected'length));
            s_OP_ASCII <= X"53524120"; --SRA

        elsif (s_OP = 12) then --lui, shift left 16
            i_ALU_CTRL <= "0100000001";
            s_overflow_chk <= '0';
            s_branch_chk <= '0';
            s_rd_chk <= '1';
            s_rd_expected <= std_logic_vector(to_signed(s_shift, s_rd_expected'length));
            s_OP_ASCII <= X"4C554920"; --LUI

        elsif (s_OP = 13) then --beq
            i_ALU_CTRL <= "1000000000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"42455120"; --BEQ

            if (s_rs_int = s_rt_int) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 14) then --bne
            i_ALU_CTRL <= "1000010000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"424E4520"; --BNE

            if (s_rs_int /= s_rt_int) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 15) then --bgez
            i_ALU_CTRL <= "0000100000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"4247455A"; --BGEZ

            if (s_rs_int >= 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 16) then --bgtz
            i_ALU_CTRL <= "0001000000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"4247545A"; --BGTZ

            if (s_rs_int > 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 17) then --blez
            i_ALU_CTRL <= "0001010000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"424C455A"; --BLEZ

            if (s_rs_int <= 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 18) then --bltz
            i_ALU_CTRL <= "0001100000";
            s_overflow_chk <= '0';
            s_branch_chk <= '1';
            s_rd_chk <= '0';
            s_OP_ASCII <= X"424C545A"; --BLTZ

            if (s_rs_int < 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        end if;
    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- ADD --
        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 100;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 0;
        s_rt_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 100;
        s_rt_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 100;
        s_rt_int <= - 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= - 100;
        s_rt_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 2147483647; --max
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 0;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '1';
        s_rs_int <= 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= - 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_rs_int <= 2147483647;
        s_rt_int <= - 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '1';
        s_rs_int <= - 2147483647;
        s_rt_int <= - 2147483647;
        wait for cCLK_PER;

        -- SUB --
        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 10;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 0;
        s_rt_int <= 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 10;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 5;
        s_rt_int <= - 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_rs_int <= - 2147483647;
        s_rt_int <= - 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '1';
        s_rs_int <= - 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '1';
        s_rs_int <= 2147483647;
        s_rt_int <= - 2147483647;
        wait for cCLK_PER;
        s_overflow_expected <= '0';

        -- LOGIC -- 

        s_OP <= 4; -- and
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 4; -- and
        s_rs_int <= - 1;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 4; -- and
        s_rs_int <= 0;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 4; -- and
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 4; -- and
        s_rs_int <= 23468;
        s_rt_int <= 67922;
        wait for cCLK_PER;

        s_OP <= 5; -- nor
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 5; -- nor
        s_rs_int <= - 1;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 5; -- nor
        s_rs_int <= 0;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 5; -- nor
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 5; -- nor
        s_rs_int <= 23468;
        s_rt_int <= 67922;
        wait for cCLK_PER;

        s_OP <= 6; -- xor
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 6; -- xor
        s_rs_int <= - 1;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 6; -- xor
        s_rs_int <= 0;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 6; -- xor
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 6; -- xor
        s_rs_int <= 23468;
        s_rt_int <= 67922;
        wait for cCLK_PER;

        s_OP <= 7; -- or
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 7; -- or
        s_rs_int <= - 1;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 7; -- or
        s_rs_int <= 0;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 7; -- or
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 7; -- or
        s_rs_int <= 23468;
        s_rt_int <= 67922;
        wait for cCLK_PER;

        -- SLT --

        s_OP <= 8; -- slt
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 0;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 5;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 100;
        s_rt_int <= 100;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= - 100;
        s_rt_int <= - 100;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 0;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 2147483647;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= - 2147483647;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 8; -- slt
        s_rs_int <= 0;
        s_rt_int <= - 2147483647;
        wait for cCLK_PER;

        -- SHIFT -- 

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 0;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= - 1;
        s_shamt_int <= 0;
        s_shift <= - 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= - 1;
        s_shamt_int <= 16;
        s_shift <= - 65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= - 1;
        s_shamt_int <= 31;
        s_shift <= - 2147483648; --expected shift output
        wait for cCLK_PER;

        s_OP <= 9; -- sll
        s_rt_int <= 284675;
        s_shamt_int <= 6;
        s_shift <= 18219200; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 0;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= - 1;
        s_shamt_int <= 0;
        s_shift <= - 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= - 1;
        s_shamt_int <= 16;
        s_shift <= 65535; --expected shift output
        wait for cCLK_PER;


        s_OP <= 10; -- srl
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= - 1;
        s_shamt_int <= 31;
        s_shift <= 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 10; -- srl
        s_rt_int <= 284675;
        s_shamt_int <= 6;
        s_shift <= 4448; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 0;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 1;
        s_shamt_int <= 0;
        s_shift <= - 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 16;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 1;
        s_shamt_int <= 16;
        s_shift <= - 1; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= 0;
        s_shamt_int <= 31;
        s_shift <= 0; --expected shift output
        wait for cCLK_PER;

        s_OP <= 11; -- sra
        s_rt_int <= - 1;
        s_shamt_int <= 31;
        s_shift <= - 1; --expected shift output
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
        s_rt_int <= - 2147483648;
        s_shamt_int <= 1;
        s_shift <= - 1073741824; --expected shift output
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
        s_rt_int <= - 1;
        s_shift <= - 65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= 65535;
        s_shift <= - 65536; --expected shift output
        wait for cCLK_PER;

        s_OP <= 12; -- lui
        s_rt_int <= 1738;
        s_shift <= 113901568; --expected shift output
        wait for cCLK_PER;
        -- BRANCH TESTING -- 

        -- TODO, ADD MORE EDGE CASES

        s_OP <= 13; -- beq
        s_rs_int <= 5;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 1;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 2147483647;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 0;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= - 2147483648;
        s_rt_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= 2147483647;
        s_rt_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= - 2147483648;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 1;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 5;
        s_rt_int <= 5;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 0;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 2147483647;
        s_rt_int <= 0;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 0;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 2147483647;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= - 2147483648;
        s_rt_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= 2147483647;
        s_rt_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= - 2147483648;
        s_rt_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        s_rs_int <= - 1;
        s_rt_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 16; -- bgtz
        s_rs_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 17; -- blez
        s_rs_int <= - 1;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 18; -- bltz
        s_rs_int <= - 1;
        wait for cCLK_PER;

        wait;
    end process;

end mixed;