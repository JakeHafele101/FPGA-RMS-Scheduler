-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- fetch.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the fetch module, 
-- 
-- 
-- Created 2/24/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity fetch is
    port (
        i_CLK        : in std_logic;                      --Clock for PC DFF
        i_PC_RST     : in std_logic;                      -- reset for PC counter DFF
        i_PC_SEL     : in std_logic_vector(1 downto 0);   -- 2 bit select line from Control Module. Dictates what output will be MUXed to PC
        i_branch     : in std_logic;                      -- indicator to branch from ALU based on operand comparison
        i_branch_chk : in std_logic;                      -- indicator to branch from Control Module based on instruction read
        i_IMM_EXT    : in std_logic_vector(31 downto 0);  -- 32 bit extended immediate, used for branch instructions
        i_RS_DATA    : in std_logic_vector(31 downto 0);  -- Contents of second source register, used for jr, PC = R[Rs]
        i_J_ADDR     : in std_logic_vector(25 downto 0);  -- adress field of J-type instruction, used for jump instructions to update PC
        o_PC         : out std_logic_vector(31 downto 0); -- Program Counter, address used to access instruction memory on top level
        o_PC_4       : out std_logic_vector(31 downto 0)  -- Program Counter + 4, wired to destination register write data for jal instruction, so $ra updates
    );
end fetch;

architecture mixed of fetch is

    -- N bit DFF to store PC
    component program_counter is
        port (
            i_CLK : in std_logic;                       -- Clock input
            i_RST : in std_logic;                       -- Reset input
            i_WE  : in std_logic;                       -- Write enable input
            i_D   : in std_logic_vector(31 downto 0);   --N bit data value input
            o_Q   : out std_logic_vector(31 downto 0)); -- N bit data value output
    end component;

    -- Adder for PC + 4, adder for branch address
    component ripple_adder is
        generic (N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port (
            i_X    : in std_logic_vector(N - 1 downto 0);  -- First operand
            i_Y    : in std_logic_vector(N - 1 downto 0);  -- Second operand
            i_Cin  : in std_logic;                         --Carry in, not needed
            o_S    : out std_logic_vector(N - 1 downto 0); --Output sum of add operation
            o_Cout : out std_logic);                       --Carry out, not needed
    end component;

    -- Internal signals for branching
    signal s_nPC4_branch : std_logic; -- select line to determine branch PC address. branch_chk from Control AND branch from ALU
    signal s_IMM_EXT_SHFT : std_logic_vector(31 downto 0);
    signal s_MUX_BRANCH : std_logic_vector(31 downto 0);

    -- Internal signals for next PC MUX
    signal s_PC : std_logic_vector(31 downto 0); -- current PC
    signal s_PC_4 : std_logic_vector(31 downto 0); -- PC + 4
    signal s_PC_jump : std_logic_vector(31 downto 0); -- {PC+4[31:28], jump address, 0b00}
    signal s_PC_branch : std_logic_vector(31 downto 0); -- (PC + 4) + (IMM shifted left 2)
    signal s_PC_next : std_logic_vector(31 downto 0); -- MUX output for next PC select

begin

    s_IMM_EXT_SHFT <= i_IMM_EXT(29 downto 0) & "00"; -- shift immediate by 2 for branch instructions
    s_PC_jump <= s_PC_4(31 downto 28) & i_J_ADDR & "00";

    g_PC_DFF : program_counter
    port map(
        i_CLK => i_CLK,     -- input clock
        i_RST => i_PC_RST,  -- IDK here, asked in Teams
        i_WE  => '1',       -- IDK here, asked in Teams
        i_D   => s_PC_next, -- next PC assignment, MUXed between PC + 4, jump address, R[Rs], branch address
        o_Q   => s_PC       -- output PC address to access instruction in Instruction Memory
    );

    -- Adder for PC + 4
    g_PC_plus_4 : ripple_adder
    port map(
        i_X    => X"00000004", -- 4
        i_Y    => s_PC,        -- PC
        i_Cin  => '0',         -- Don't need carry in, set to 0 so no additional add
        o_S    => s_PC_4,      -- PC + 4
        o_Cout => open         -- Don't need carry out, leave open
    );

    -- Adder for branch address, sums bit shifted immediate and PC + 4
    g_PC4_plus_branch : ripple_adder
    port map(
        i_X    => s_PC_4,         -- PC + 4
        i_Y    => s_IMM_EXT_SHFT, -- Immediate shifted left by 2 bits (aka multiplied by 4)
        i_Cin  => '0',            -- Don't need carry in, set to 0 so no additional add
        o_S    => s_PC_branch,    -- Branch address for PC
        o_Cout => open            -- Don't need carry out, leave open
    );

    s_nPC4_branch <= i_branch_chk and i_branch; -- assignment of select line for branch MUX

    with s_nPC4_branch select
        s_MUX_BRANCH <= s_PC_4 when '0', -- When 0, PC + 4 routed to output
        s_PC_branch when '1', -- When 1, branch address routed to output
        s_PC_4 when others; 

    with i_PC_SEL select
        s_PC_next <= s_PC_4 when "00",
        s_PC_jump when "01",
        i_RS_DATA when "10",
        s_MUX_BRANCH when "11",
        s_PC_4 when others;

    o_PC <= s_PC;
    o_PC_4 <= s_PC_4;


end mixed;