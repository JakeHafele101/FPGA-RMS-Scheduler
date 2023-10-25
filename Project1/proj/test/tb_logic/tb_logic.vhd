-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_logic.vhd
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

entity tb_logic is
    generic (gCLK_HPER : time := 2 ns);
end tb_logic;

architecture mixed of tb_logic is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component logic is
        port (
            i_logic_Sel : in std_logic_vector(1 downto 0);
            i_rs        : in std_logic_vector(31 downto 0);
            i_rt        : in std_logic_vector(31 downto 0);
            o_result    : out std_logic_vector(31 downto 0));
    end component;

    -- Input signals of tested module
    signal i_logic_Sel : std_logic_vector (1 downto 0) := "00"; --10 ALU Control bits
    signal i_rs, i_rt : std_logic_vector (31 downto 0) := X"00000000"; --Input operands

    -- Output signals of tested module
    signal o_result : std_logic_vector (31 downto 0);

    -- Test signals
    signal s_result_expected : std_logic_vector(31 downto 0);

    signal s_OP : integer;
    signal s_OP_ASCII : std_logic_vector(31 downto 0);

    signal s_rs_int, s_rt_int : integer := 0;

    signal s_result_error : std_logic := '0';

begin

    DUT0 : logic
    port map(
        i_logic_Sel => i_logic_Sel,
        i_rs        => i_rs,
        i_rt        => i_rt,
        o_result    => o_result
    );

    i_rs <= std_logic_vector(to_signed(s_rs_int, i_rs'length));
    i_rt <= std_logic_vector(to_signed(s_rt_int, i_rt'length));

    P_RD_CHK : process
    begin

        wait for gCLK_HPER;

        if (s_result_expected /= o_result) then
            s_result_error <= '1';
        else
            s_result_error <= '0';
        end if;
    end process;

    P_OP : process (s_OP, i_rs, i_rt) is
    begin

    if (s_OP = 4) then --and
        i_logic_sel <= "00";
        s_result_expected <= i_rs and i_rt;
        s_OP_ASCII <= X"414E4420"; --AND

    elsif (s_OP = 5) then --nor
        i_logic_sel <= "01";
        s_result_expected <= i_rs nor i_rt;
        s_OP_ASCII <= X"4E4F5220"; --NOR

    elsif (s_OP = 6) then --xor
        i_logic_sel <= "10";
        s_result_expected <= i_rs xor i_rt;
        s_OP_ASCII <= X"584F5220"; --XOR

    elsif (s_OP = 7) then --or
        i_logic_sel <= "11";
        s_result_expected <= i_rs or i_rt;
        s_OP_ASCII <= X"4F522020"; --OR

    end if;
end process;

-- Testbench process  
P_DUT0 : process
begin

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

    wait;
end process;

end mixed;