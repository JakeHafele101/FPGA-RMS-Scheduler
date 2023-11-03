-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ID_EX_BufferReg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- 
-- Created 3/23/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX_BufferReg is
    port (
        i_CLK   : in std_logic; -- Clock input
        i_RST   : in std_logic; -- Reset input
        i_stall : in std_logic; -- Write Enable to all registers
        i_flush : in std_logic; -- If 1, write 0 to all regs

        i_ID_OPCODE           : in std_logic_vector(5 downto 0);
        i_ID_FUNCT            : in std_logic_vector(5 downto 0);
        i_ID_reg_WE_SEL       : in std_logic_vector(0 downto 0);
        i_ID_Halt             : in std_logic_vector(0 downto 0);
        i_ID_ALUSrc           : in std_logic_vector(0 downto 0);
        i_ID_overflow_chk     : in std_logic_vector(0 downto 0);
        i_ID_reg_DST_ADDR_SEL : in std_logic_vector(1 downto 0);
        i_ID_reg_DST_DATA_SEL : in std_logic_vector(1 downto 0);
        i_ID_reg_WE           : in std_logic_vector(0 downto 0);
        i_ID_mem_WE           : in std_logic_vector(0 downto 0);
        i_ID_nAdd_Sub         : in std_logic_vector(0 downto 0);
        i_ID_shift_SEL        : in std_logic_vector(1 downto 0);
        i_ID_logic_SEL        : in std_logic_vector(1 downto 0);
        i_ID_out_SEL          : in std_logic_vector(1 downto 0);
        i_ID_branch           : in std_logic_vector(0 downto 0);
        i_ID_PC_4             : in std_logic_vector(31 downto 0);
        i_ID_rs_ADDR          : in std_logic_vector(4 downto 0);
        i_ID_rt_ADDR          : in std_logic_vector(4 downto 0);
        i_ID_rd_ADDR          : in std_logic_vector(4 downto 0);
        i_ID_SHAMT            : in std_logic_vector(4 downto 0);
        i_ID_rs_DATA          : in std_logic_vector(31 downto 0);
        i_ID_rt_DATA          : in std_logic_vector(31 downto 0);
        i_ID_IMM_EXT          : in std_logic_vector(31 downto 0);

        o_EX_OPCODE           : out std_logic_vector(5 downto 0);
        o_EX_FUNCT            : out std_logic_vector(5 downto 0);
        o_EX_reg_WE_SEL       : out std_logic_vector(0 downto 0);
        o_EX_Halt             : out std_logic_vector(0 downto 0);
        o_EX_ALUSrc           : out std_logic_vector(0 downto 0);
        o_EX_overflow_chk     : out std_logic_vector(0 downto 0);
        o_EX_reg_DST_ADDR_SEL : out std_logic_vector(1 downto 0);
        o_EX_reg_DST_DATA_SEL : out std_logic_vector(1 downto 0);
        o_EX_reg_WE           : out std_logic_vector(0 downto 0);
        o_EX_mem_WE           : out std_logic_vector(0 downto 0);
        o_EX_nAdd_Sub         : out std_logic_vector(0 downto 0);
        o_EX_shift_SEL        : out std_logic_vector(1 downto 0);
        o_EX_logic_SEL        : out std_logic_vector(1 downto 0);
        o_EX_out_SEL          : out std_logic_vector(1 downto 0);
        o_EX_branch           : out std_logic_vector(0 downto 0);
        o_EX_PC_4             : out std_logic_vector(31 downto 0);
        o_EX_rs_ADDR          : out std_logic_vector(4 downto 0);
        o_EX_rt_ADDR          : out std_logic_vector(4 downto 0);
        o_EX_rd_ADDR          : out std_logic_vector(4 downto 0);
        o_EX_SHAMT            : out std_logic_vector(4 downto 0);
        o_EX_rs_DATA          : out std_logic_vector(31 downto 0);
        o_EX_rt_DATA          : out std_logic_vector(31 downto 0);
        o_EX_IMM_EXT          : out std_logic_vector(31 downto 0));
end ID_EX_BufferReg;

architecture structural of ID_EX_BufferReg is

    component reg_N_buff is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_CLK   : in std_logic;                          -- Clock input
            i_RST   : in std_logic;                          -- Reset input
            i_WE    : in std_logic;                          -- Write enable input
            i_D     : in std_logic_vector(N - 1 downto 0);   --N bit data value input
            i_stall : in std_logic;                          -- If stall, write 0's to register
            i_flush : in std_logic;                          -- If flush is 1, write 0's to reg
            o_Q     : out std_logic_vector(N - 1 downto 0)); -- N bit data value output
    end component;

begin

    REG_OPCODE : reg_N_buff
    generic map(N => 6)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_OPCODE,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_OPCODE
    );

    REG_FUNCT : reg_N_buff
    generic map(N => 6)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_FUNCT,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_FUNCT
    );

    REG_reg_WE_SEL : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_reg_WE_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_reg_WE_SEL
    );

    REG_halt : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_Halt,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_Halt
    );

    REG_ALUSrc : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_ALUSrc,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_ALUSrc
    );

    REG_overflow_chk : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_overflow_chk,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_overflow_chk
    );

    REG_reg_DST_ADDR_SEL : reg_N_buff
    generic map(N => 2)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_reg_DST_ADDR_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_reg_DST_ADDR_SEL
    );

    REG_reg_DST_DATA_SEL : reg_N_buff
    generic map(N => 2)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_reg_DST_DATA_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_reg_DST_DATA_SEL
    );

    REG_reg_WE : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_reg_WE,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_reg_WE
    );

    REG_mem_WE : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_mem_WE,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_mem_WE
    );

    REG_nAdd_Sub : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_nAdd_Sub,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_nAdd_Sub
    );

    REG_shift_SEL : reg_N_buff
    generic map(N => 2)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_shift_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_shift_SEL
    );

    REG_logic_SEL : reg_N_buff
    generic map(N => 2)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_logic_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_logic_SEL
    );

    REG_out_SEL : reg_N_buff
    generic map(N => 2)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_out_SEL,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_out_SEL
    );

    REG_branch : reg_N_buff
    generic map(N => 1)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_branch,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_branch
    );

    REG_PC_4 : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_PC_4,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_PC_4
    );

    REG_rt_ADDR : reg_N_buff
    generic map(N => 5)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_rt_ADDR,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_rt_ADDR
    );

    REG_rs_ADDR : reg_N_buff
    generic map(N => 5)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_rs_ADDR,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_rs_ADDR
    );

    REG_rd_ADDR : reg_N_buff
    generic map(N => 5)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_rd_ADDR,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_rd_ADDR
    );

    REG_SHAMT : reg_N_buff
    generic map(N => 5)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_SHAMT,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_SHAMT
    );

    REG_rs_DATA : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_rs_DATA,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_rs_DATA
    );

    REG_rt_DATA : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_rt_DATA,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_rt_DATA
    );

    REG_IMM_EXT : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ID_IMM_EXT,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q   => o_EX_IMM_EXT
    );
end structural;