-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- IF_ID_BufferReg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- 
-- Created 3/23/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID_BufferReg is
    port (
        i_CLK   : in std_logic; -- Clock input
        i_RST   : in std_logic; -- Reset input
        i_stall : in std_logic; -- Write Enable to all registers
        i_flush : in std_logic; -- If 1, write 0 to all regs

        i_IF_PC_4  : in std_logic_vector(31 downto 0);
        i_IF_Instr : in std_logic_vector(31 downto 0);

        o_ID_PC_4  : out std_logic_vector(31 downto 0);
        o_ID_Instr : out std_logic_vector(31 downto 0));
end IF_ID_BufferReg;

architecture structural of IF_ID_BufferReg is

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

    reg_PC_4 : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_IF_PC_4,
        i_stall => i_stall,
        i_flush => i_flush, 
        o_Q     => o_ID_PC_4
    );

    REG_Instr : reg_N_buff
    generic map(N => 32)
    port map(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_IF_Instr,
        i_stall => i_stall,
        i_flush => i_flush,
        o_Q     => o_ID_Instr
    );

end structural;