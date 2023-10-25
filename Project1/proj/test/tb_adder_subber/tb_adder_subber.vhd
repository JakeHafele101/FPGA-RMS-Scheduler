-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_adder_subber.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- adder_subber module in our Single Cycle MIPS Processor adder_subber
--
--
-- NOTES:
-- Created 3/7/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adder_subber is
    generic (gCLK_HPER : time := 2 ns);
end tb_adder_subber;

architecture mixed of tb_adder_subber is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component adder_subber is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_A        : in std_logic_vector(N - 1 downto 0);
            i_B        : in std_logic_vector(N - 1 downto 0);
            i_nAdd_Sub : in std_logic;
            o_S        : out std_logic_vector(N - 1 downto 0);
            o_overflow : out std_logic;
            o_Cout     : out std_logic);
    end component;

    -- Input signals of tested module
    signal i_A, i_B : std_logic_vector (31 downto 0) := X"00000000"; --Input operands
    signal i_nAdd_Sub : std_logic := '0'; --10 adder_subber Control bits
    -- Output signals of tested module
    signal o_S : std_logic_vector (31 downto 0);
    signal o_overflow, o_Cout : std_logic;

    -- Test signals
    signal s_overflow_expected, s_Cout_expected : std_logic := '0';
    signal s_S_expected : std_logic_vector(31 downto 0);

    signal s_OP : integer;
    signal s_OP_ASCII : std_logic_vector(31 downto 0);

    signal s_A_int, s_B_int : integer := 0;
    signal s_add, s_sub : integer;

    signal s_overflow_error, s_S_error, s_Cout_error : std_logic := '0';

begin

    DUT0 : adder_subber
    port map(
        i_A        => i_A,
        i_B        => i_B,
        i_nAdd_Sub => i_nAdd_Sub,
        o_S        => o_S,
        o_overflow => o_overflow,
        o_Cout     => o_Cout
    );

    i_A <= std_logic_vector(to_signed(s_A_int, i_A'length));
    i_B <= std_logic_vector(to_signed(s_B_int, i_B'length));

    s_add <= s_A_int + s_B_int;
    s_sub <= s_A_int - s_B_int;

    P_OVERFLOW_CHK : process (o_overflow) is
    begin

        if ((s_overflow_expected xor o_overflow) = '1') then
            s_overflow_error <= '1';
        else
            s_overflow_error <= '0';
        end if;
    end process;

    P_COUT_CHK : process (o_Cout) is
    begin

        if ((s_Cout_expected xor o_Cout) = '1') then
            s_Cout_error <= '1';
        else
            s_Cout_error <= '0';
        end if;
    end process;

    P_S_CHK : process
    begin

        wait for gCLK_HPER;

        if (s_S_expected /= o_S) then
            s_S_error <= '1';
        else
            s_S_error <= '0';
        end if;
    end process;

    P_OP : process (s_OP, i_A, i_B) is
    begin

        if (s_OP = 0) then --add
            i_nAdd_Sub <= '0';
            s_S_expected <= std_logic_vector(to_signed(s_add, s_S_expected'length));
            s_OP_ASCII <= X"41444420"; -- ADD

        elsif (s_OP = 2) then --sub
            i_nAdd_Sub <= '1';
            s_S_expected <= std_logic_vector(to_signed(s_sub, s_S_expected'length));
            s_OP_ASCII <= X"53554220"; --SUB

        end if;
    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- ADD --
        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 0;
        s_B_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 100;
        s_B_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 0;
        s_B_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 100;
        s_B_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 100;
        s_B_int <= - 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= - 100;
        s_B_int <= 200;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 2147483647; --max
        s_B_int <= 0;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 0;
        s_B_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '1';
        s_Cout_expected <= '1';
        s_A_int <= 2147483647;
        s_B_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= - 2147483647;
        s_B_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 2147483647;
        s_B_int <= - 2147483647;
        wait for cCLK_PER;

        s_OP <= 0; --add
        s_overflow_expected <= '1';
        s_Cout_expected <= '1';
        s_A_int <= - 2147483647;
        s_B_int <= - 2147483647;
        wait for cCLK_PER;

        -- SUB --
        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 0;
        s_B_int <= 0;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 10;
        s_B_int <= 0;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 0;
        s_B_int <= 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 10;
        s_B_int <= 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 10;
        s_B_int <= -10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= -10;
        s_B_int <= 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= -10;
        s_B_int <= -10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 10;
        s_B_int <= 5;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '0';
        s_A_int <= 5;
        s_B_int <= - 10;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= 2147483647;
        s_B_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '0';
        s_Cout_expected <= '1';
        s_A_int <= - 2147483647;
        s_B_int <= - 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '1';
        s_Cout_expected <= '1';
        s_A_int <= - 2147483647;
        s_B_int <= 2147483647;
        wait for cCLK_PER;

        s_OP <= 2; -- sub
        s_overflow_expected <= '1';
        s_Cout_expected <= '0';
        s_A_int <= 2147483647;
        s_B_int <= - 2147483647;
        wait for cCLK_PER;
        s_overflow_expected <= '0';

        wait;
    end process;

end mixed;