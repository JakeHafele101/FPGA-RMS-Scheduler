-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- first_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- adder subtractor unit that can add/sub together 2 registers or 1 register 
-- and a 32 bit immediate value and a 32 bit register file. 
-- 
-- Created 2/3/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity first_datapath is
    port (
        i_CLK      : in std_logic;                      -- Clock input
        i_RST      : in std_logic;                      -- Reset input
        i_RS       : in std_logic_vector(4 downto 0);   -- RS first operand reg num
        i_RT       : in std_logic_vector(4 downto 0);   -- RT second operand reg num
        i_RD       : in std_logic_vector(4 downto 0);   -- Write enable input
        i_RD_WE    : in std_logic;                      -- Write enable input
        i_IMM      : in std_logic_vector (31 downto 0); -- 32 bit immediate value for add/sub
        i_nAdd_Sub : in std_logic;                      -- if 0, add. if 1, subtract
        i_ALU_SRC  : in std_logic);                     -- if 0, second operand is register RT. If 1, second op is immediate
end first_datapath;

architecture structural of first_datapath is

    component reg_file is
        port (
            i_CLK     : in std_logic;                       -- Clock input
            i_RST     : in std_logic;                       -- Reset input
            i_RS      : in std_logic_vector(4 downto 0);    -- RS first operand reg num
            i_RT      : in std_logic_vector(4 downto 0);    -- RT second operand reg num
            i_RD      : in std_logic_vector(4 downto 0);    -- Write enable input
            i_RD_WE   : in std_logic;                       -- Write enable for destination reg RD
            i_RD_DATA : in std_logic_vector(31 downto 0);   -- RD destination reg to write to
            o_RS_DATA : out std_logic_vector(31 downto 0);  -- RS reg data output
            o_RT_DATA : out std_logic_vector(31 downto 0)); -- RT reg data output
    end component;

    component add_sub_imm is
        port (
            i_A        : in std_logic_vector(31 downto 0);  -- First register operand
            i_B        : in std_logic_vector(31 downto 0);  -- Second register operand
            i_IMM      : in std_logic_vector(31 downto 0);  -- Second immediate operand
            i_nAdd_Sub : in std_logic;                      -- if 0, add. If 1, subtract
            i_ALU_SRC  : in std_logic;                      -- if 0, use second register i_B. If 1, use second immediate i_IMM
            o_S        : out std_logic_vector(31 downto 0); -- Output sum from add/sub operation
            o_Cout     : out std_logic);                    -- carry out bit, not used
    end component;

    --internal signals
    signal s_RD_DATA, s_RS_DATA, s_RT_DATA : std_logic_vector(31 downto 0);
begin

    --instantiate components
    g_reg_file : reg_file
    port map(
        i_CLK     => i_CLK,    -- Clock input
        i_RST     => i_RST,     -- Reset input
        i_RS      => i_RS,      -- RS first operand reg num
        i_RT      => i_RT,      -- RT second operand reg num
        i_RD      => i_RD,      -- Write enable input
        i_RD_WE   => i_RD_WE,   -- Write enable for destination reg RD
        i_RD_DATA => s_RD_DATA, -- RD destination reg to write to
        o_RS_DATA => s_RS_DATA, -- RS reg data output
        o_RT_DATA => s_RT_DATA -- RT reg data output
    );

    g_add_sub_imm : add_sub_imm
    port map(
        i_A        => s_RS_DATA,  -- First register operand
        i_B        => s_RT_DATA,   -- Second register operand
        i_IMM      => i_IMM,       -- Second immediate operand
        i_nAdd_Sub => i_nAdd_Sub,  -- if 0, add. If 1, subtract
        i_ALU_SRC  => i_ALU_SRC,   -- if 0, use second register i_B. If 1, use second immediate i_IMM
        o_S        => s_RD_DATA,   -- Output sum from add/sub operation
        o_Cout     => open        -- carry out bit, not used
    );

end structural;