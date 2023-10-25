-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 32-bit register
-- file with 32 MIPS registers. It includes a clock, reset pin, and lots 
-- of fun
-- 
-- Created 2/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity reg_file is
    port (
        i_CLK     : in std_logic;                       -- Clock input
        i_RST     : in std_logic;                       -- Reset input
        i_rs_ADDR      : in std_logic_vector(4 downto 0);    -- RS first operand reg num
        i_rt_ADDR : in std_logic_vector(4 downto 0);    -- RT second operand reg num
        i_rd_ADDR : in std_logic_vector(4 downto 0);    -- Write enable input
        i_rd_WE   : in std_logic;                       -- Write enable for destination reg RD
        i_rd_DATA : in std_logic_vector(31 downto 0);   -- RD destination reg to write to
        o_rs_DATA : out std_logic_vector(31 downto 0);  -- RS reg data output
        o_rt_DATA : out std_logic_vector(31 downto 0)); -- RT reg data output
end reg_file;

architecture structural of reg_file is

    component decoder_5t32 is
        port (
            i_A  : in std_logic_vector(4 downto 0); --5 bit data value input
            i_WE : in std_logic;
            o_F  : out std_logic_vector(31 downto 0)); -- 32 bit data value output
    end component;

    component reg_N is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_CLK : in std_logic;                          -- Clock input
            i_RST : in std_logic;                          -- Reset input
            i_WE  : in std_logic;                          -- Write enable input
            i_D   : in std_logic_vector(N - 1 downto 0);   --N bit data value input
            o_Q   : out std_logic_vector(N - 1 downto 0)); -- N bit data value output
    end component;

    component mux_32t1_32b is
        port (
            i_S : in std_logic_vector(4 downto 0);
            i_D : in word_array(31 downto 0); --32, 32 bit widestd_logic_vectors w
            o_O : out std_logic_vector(31 downto 0));
    end component;

    -- Internal signals
    signal s_RD_WE : std_logic_vector(31 downto 0);
    signal s_REG_DATA : word_array(31 downto 0);
begin

    -- Instantiate decoder
    G_5t32_DECODER : decoder_5t32
    port map(
        i_A  => i_rd_ADDR,
        i_WE => i_rd_WE,
        o_F  => s_RD_WE);

    -- 0 register that always outputs 0x00000000
    REG_0 : reg_N
    port map(
        i_CLK => i_CLK,          -- All instances share the same clock input
        i_RST => '1',            -- All instances share the same reset input
        i_WE  => s_RD_WE(0),     -- All instances share the same write enable input
        i_D   => i_rd_DATA,      -- ith instance's data input hooked up to ith data input.
        o_Q   => s_REG_DATA(0)); -- ith instance's data output hooked up to ith data output.

    -- Instantiate  regs 1 to 31
    G_N_32bit_Reg : for i in 1 to 31 generate
        REG_I : reg_N
        port map(
            i_CLK => i_CLK,          -- All instances share the same clock input
            i_RST => i_RST,          -- All instances share the same reset input
            i_WE  => s_RD_WE(i),     -- All instances share the same write enable input
            i_D   => i_rd_DATA,      -- ith instance's data input hooked up to ith data input.
            o_Q   => s_REG_DATA(i)); -- ith instance's data output hooked up to ith data output.
    end generate G_N_32bit_Reg;

    -- instantiate RS MUX
    G_MUX_RS : mux_32t1_32b
    port map(
        i_S => i_rs_ADDR,
        i_D => s_REG_DATA,
        o_O => o_rs_DATA
    );

    -- instantiate RT MUX
    G_MUX_RT : mux_32t1_32b
    port map(
        i_S => i_rt_ADDR,
        i_D => s_REG_DATA,
        o_O => o_rt_DATA
    );

end structural;