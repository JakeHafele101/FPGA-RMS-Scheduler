-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_extend_16t32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level register file extend_16t32.vhd
--
--
-- NOTES:
-- Created 2/4/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_extend_16t32 is
    generic (gCLK_HPER : time := 10 ns);
end tb_extend_16t32;

architecture mixed of tb_extend_16t32 is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component extend_16t32 is
        port (
            i_A          : in std_logic_vector(15 downto 0);   --16 bit input
            i_nZero_Sign : in std_logic := '1';                --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
            o_F          : out std_logic_vector(31 downto 0)); --32 bit output
    end component;

    -- Input signals of tested module
    signal i_A : std_logic_vector(15 downto 0) := X"0000";
    signal i_nZero_Sign : std_logic := '0';

    -- Output signals of tested module
    signal o_F : std_logic_vector(31 downto 0);

    -- Internal test signals of testbench
    signal s_F_Expected : std_logic_vector(31 downto 0) := X"00000000";
    signal s_F_Mismatch : std_logic := '0';

begin

    DUT0 : extend_16t32
    port map(
        i_A          => i_A,
        i_nZero_Sign => i_nZero_Sign,
        o_F          => o_F);

    --Expected vs actual check
    P_MISMATCH : process
    begin
        wait for gCLK_HPER * 1.5; --wait after pos edge for signals to update

        if (o_F /= s_F_Expected) then
            report "o_F error at time " & time'image(now);
            s_F_Mismatch <= '1';
        else
            s_F_Mismatch <= '0';
        end if;

        wait for gCLK_HPER / 2;

    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- Extend 0's
        i_A <= X"0001";
        i_nZero_Sign <= '0';
        s_F_Expected <= X"00000001";
        wait for cCLK_PER;

        -- Extend 0's
        i_A <= X"8002";
        i_nZero_Sign <= '0';
        s_F_Expected <= X"00008002";
        wait for cCLK_PER;

        -- Extend 0's
        i_A <= X"0003";
        i_nZero_Sign <= '1';
        s_F_Expected <= X"00000003";
        wait for cCLK_PER;

        -- Extend 1's
        i_A <= X"8004";
        i_nZero_Sign <= '1';
        s_F_Expected <= X"FFFF8004";
        wait for cCLK_PER;

        wait;
    end process;

end mixed;