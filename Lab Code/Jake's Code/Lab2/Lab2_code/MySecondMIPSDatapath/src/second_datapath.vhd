-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- second_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of my second datapath,
-- which includes a basic adder/subtractor unit that uses two register 
-- operands or 1 register and one immediate. This datapath also includes 
-- a memory module, enabling the sw and lw instructions. 
-- 
-- Created 2/6/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity second_datapath is
    port (
        i_CLK        : in std_logic;                      -- Clock input
        i_RST        : in std_logic;                      -- Reset input
        i_RS         : in std_logic_vector(4 downto 0);   -- RS first operand reg num
        i_RT         : in std_logic_vector(4 downto 0);   -- RT second operand reg num
        i_RD         : in std_logic_vector(4 downto 0);   -- Write enable input
        i_RD_WE      : in std_logic;                      -- Write enable input
        i_IMM        : in std_logic_vector (15 downto 0); -- 32 bit immediate value for add/sub
        i_nAdd_Sub   : in std_logic;                      -- if 0, add. if 1, subtract
        i_ALU_SRC    : in std_logic;                      -- if 0, second operand is register RT. If 1, second op is immediate
        i_SW         : in std_logic;                      -- if 1, load word from memory from address (R[RT] + Immediate), load to R[RT]
        i_nADDER_MEM : in std_logic);                     -- if 1, store word into memory at address R[RT] + Immediate
end second_datapath;

architecture structural of second_datapath is

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

    component extend_16t32 is
        port (
            i_A          : in std_logic_vector(15 downto 0); --16 bit input
            i_nZero_Sign : in std_logic := '1';              --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
            o_F          : out std_logic_vector(31 downto 0) --32 bit output
        );
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

    component dmem is
        generic (
            DATA_WIDTH : natural := 32; -- Width of bits for each i_ADDRess
            ADDR_WIDTH : natural := 32); -- Width of i_ADDRess as 2^(ADDR_WIDTH - 1)
        port (
            i_CLK  : in std_logic;
            i_ADDR : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
            i_DATA : in std_logic_vector((DATA_WIDTH - 1) downto 0);
            i_WE   : in std_logic := '1';
            o_Q    : out std_logic_vector((DATA_WIDTH - 1) downto 0));
    end component;

    component mux2t1_N is
        generic (N : integer := 16); -- Generic of type integer for input/output data width. Default value is 16.
        port (
            i_S  : in std_logic;                          -- Select Line
            i_D0 : in std_logic_vector(N - 1 downto 0);   -- Output if S = 0
            i_D1 : in std_logic_vector(N - 1 downto 0);   -- Output if S = 1
            o_O  : out std_logic_vector(N - 1 downto 0)); -- Selected output
    end component;

    --internal signals
    signal s_ARITH_DATA, s_MEM_DATA, s_RD_DATA_MUX : std_logic_vector(31 downto 0); --Outputs from arithemtic and memory module, output MUXED data to go into reg file
    signal s_RS_DATA, s_RT_DATA : std_logic_vector(31 downto 0); --register values at R[RS] and R[RT] from reg file
    signal s_IMM_32B : std_logic_vector(31 downto 0); -- 32 bit extended immediate value
begin

    g_mux2t1_RD_Data : mux2t1_N
    generic map(N => 32)
    port map(
        i_S  => i_nADDER_MEM,
        i_D0 => s_ARITH_DATA,
        i_D1 => s_MEM_DATA,
        o_O  => s_RD_DATA_MUX
    );

    --instantiate components
    g_reg_file : reg_file
    port map(
        i_CLK     => i_CLK,         -- Clock input
        i_RST     => i_RST,         -- Reset input
        i_RS      => i_RS,          -- RS first operand reg num
        i_RT      => i_RT,          -- RT second operand reg num
        i_RD      => i_RD,      -- Write enable input
        i_RD_WE   => i_RD_WE,       -- Write enable for destination reg RD
        i_RD_DATA => s_RD_DATA_MUX, -- RD destination reg to write to
        o_RS_DATA => s_RS_DATA,     -- RS reg data output
        o_RT_DATA => s_RT_DATA      -- RT reg data output
    );

    g_extend_16t32 : extend_16t32
    port map(
        i_A          => i_IMM,    --16 bit input
        i_nZero_Sign => '1',      --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
        o_F          => s_IMM_32B --32 bit output
    );

    g_add_sub_imm : add_sub_imm
    port map(
        i_A        => s_RS_DATA,    -- First register operand
        i_B        => s_RT_DATA,    -- Second register operand
        i_IMM      => s_IMM_32B,    -- Second immediate operand
        i_nAdd_Sub => i_nAdd_Sub,   -- if 0, add. If 1, subtract
        i_ALU_SRC  => i_ALU_SRC,    -- if 0, use second register i_B. If 1, use second immediate i_IMM
        o_S        => s_ARITH_DATA, -- Output sum from add/sub operation
        o_Cout     => open          -- carry out bit, not used
    );

    g_dmem : dmem
    generic map(
        DATA_WIDTH => 32, -- Width of bits for each i_ADDRess
        ADDR_WIDTH => 10 -- Width of i_ADDR as 2^(ADDR_WIDTH - 1)
    )
    port map(
        i_CLK  => i_CLK,
        i_ADDR => s_ARITH_DATA(9 downto 0),
        i_DATA => s_RT_DATA,
        i_WE   => i_SW,
        o_Q    => s_MEM_DATA
    );

end structural;