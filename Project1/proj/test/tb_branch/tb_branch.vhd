-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_branch.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- branch module in our ALU design
--
--
-- NOTES:
-- Created 3/7/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_branch is
    generic (gCLK_HPER : time := 2 ns);
end tb_branch;

architecture mixed of tb_branch is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component branch is
        port (
            i_branch_Sel : in std_logic_vector(2 downto 0);
            i_rs         : in std_logic_vector(31 downto 0);
            i_zero       : in std_logic;
            o_branch     : out std_logic);
    end component;

    -- Input signals of tested module
    signal i_branch_Sel : std_logic_vector (2 downto 0) := "000";
    signal i_rs : std_logic_vector (31 downto 0) := X"00000000"; --Input operands
    signal i_zero : std_logic := '0';

    -- Output signals of tested module
    signal o_branch : std_logic;

    -- Test signals
    signal s_branch_expected : std_logic := '0';

    signal s_OP : integer;
    signal s_OP_ASCII : std_logic_vector(31 downto 0);

    signal s_rs_int : integer := 0;

    signal s_branch_error : std_logic := '0';

begin

    DUT0 : branch
    port map(
        i_branch_Sel => i_branch_Sel,
        i_rs         => i_rs,
        i_zero       => i_zero,
        o_branch     => o_branch
    );

    i_rs <= std_logic_vector(to_signed(s_rs_int, i_rs'length));

    P_BRANCH_CHK : process
    begin

        wait for gCLK_HPER;

        if ((s_branch_expected xor o_branch) = '1') then
            s_branch_error <= '1';
        else
            s_branch_error <= '0';
        end if;
    end process;

    P_OP : process (s_OP, i_rs, i_zero) is
    begin

        if (s_OP = 13) then --beq
            i_branch_Sel <= "000";
            s_OP_ASCII <= X"42455120"; --BEQ

            if (i_zero = '1') then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 14) then --bne
            i_branch_Sel <= "001";
            s_OP_ASCII <= X"424E4520"; --BNE

            if (i_zero = '0') then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 15) then --bgez
            i_branch_Sel <= "010";
            s_OP_ASCII <= X"4247455A"; --BGEZ

            if (s_rs_int >= 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 16) then --bgtz
            i_branch_Sel <= "100";
            s_OP_ASCII <= X"4247545A"; --BGTZ

            if (s_rs_int > 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 17) then --blez
            i_branch_Sel <= "101";
            s_OP_ASCII <= X"424C455A"; --BLEZ

            if (s_rs_int <= 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 18) then --bltz
            i_branch_Sel <= "111";
            s_OP_ASCII <= X"424C545A"; --BLTZ

            if (s_rs_int < 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 19) then --bgezal
            i_branch_Sel <= "011";
            s_OP_ASCII <= X"42475A4C"; --BGZL

            if (s_rs_int >= 0) then
                s_branch_expected <= '1';
            else
                s_branch_expected <= '0';
            end if;

        elsif (s_OP = 20) then --bltzal
            i_branch_Sel <= "110";
            s_OP_ASCII <= X"424C5A4C"; --BLZL

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

        s_OP <= 13; -- beq
        i_zero <= '0';
        wait for cCLK_PER;

        s_OP <= 13; -- beq
        i_zero <= '1';
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        i_zero <= '0';
        wait for cCLK_PER;

        s_OP <= 14; -- bne
        i_zero <= '1';
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
        s_rs_int <= -2147483648;
        wait for cCLK_PER;

        s_OP <= 15; -- bgez
        s_rs_int <= -1;
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

        s_OP <= 19; -- bgezal
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 19; -- bgezal
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 19; -- bgezal
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 19; -- bgezal
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 19; -- bgezal
        s_rs_int <= -2147483648;
        wait for cCLK_PER;

        s_OP <= 19; -- bgezal
        s_rs_int <= -1;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= - 5;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= 0;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= 5;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= - 2147483648;
        wait for cCLK_PER;

        s_OP <= 20; -- bltzal
        s_rs_int <= - 1;
        wait for cCLK_PER;

        wait;
    end process;

end mixed;