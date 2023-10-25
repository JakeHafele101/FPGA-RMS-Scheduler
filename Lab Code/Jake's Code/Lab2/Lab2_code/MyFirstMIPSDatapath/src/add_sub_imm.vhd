-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- add_sub_imm.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- adder subtractor unit that can add/sub together 2 registers or 1 register 
-- and a 32 bit immediate value
-- 
-- Created 2/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub_imm is
    port (
        i_A        : in std_logic_vector(31 downto 0);  -- First register operand
        i_B        : in std_logic_vector(31 downto 0);  -- Second register operand
        i_IMM      : in std_logic_vector(31 downto 0);  -- Second immediate operand
        i_nAdd_Sub : in std_logic;                      -- if 0, add. If 1, subtract
        i_ALU_SRC  : in std_logic;                      -- if 0, use second register i_B. If 1, use second immediate i_IMM
        o_S        : out std_logic_vector(31 downto 0); -- Output sum from add/sub operation
        o_Cout     : out std_logic);                    --carry out bit, not used
end add_sub_imm;

architecture structural of add_sub_imm is

    component mux2t1_N is
        generic (N : integer := 16); -- Generic of type integer for input/output data width. Default value is 16.
        port (
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(31 downto 0);
            i_D1 : in std_logic_vector(31 downto 0);
            o_O  : out std_logic_vector(31 downto 0));
    end component;

    component adder_subber is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_A        : in std_logic_vector(N - 1 downto 0);
            i_B        : in std_logic_vector(N - 1 downto 0);
            i_nAdd_Sub : in std_logic;
            o_S        : out std_logic_vector(N - 1 downto 0);
            o_Cout     : out std_logic);
    end component;

    -- Internal signals
    signal s_OP_B : std_logic_vector (31 downto 0); -- operand Y of 

begin

    g_mux2t1_N : mux2t1_N
    generic map(N => 32)
    port map(
        i_S  => i_ALU_SRC,
        i_D0 => i_B,
        i_D1 => i_IMM,
        o_O  => s_OP_B);

    g_adder_subber : adder_subber
    generic map(N => 32)
    port map(
        i_A        => i_A,
        i_B        => s_OP_B,
        i_nAdd_Sub => i_nAdd_Sub,
        o_S        => o_S,
        o_Cout     => o_Cout);

end structural;