-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_Fetch.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level Fetch file in our Single Cycle MIPS Processor
--
--
-- NOTES:
-- Created 2/27/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Fetch is
    generic (gCLK_HPER : time := 10 ns);
end tb_Fetch;

architecture mixed of tb_Fetch is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component Fetch is
        port (
            i_CLK        : in std_logic;                       --Clock for PC DFF
            i_PC_RST     : in std_logic;                       -- reset for PC counter DFF
            i_PC_SEL     : in std_logic_vector(1 downto 0);    -- 2 bit select line from Control Module. Dictates what output will be MUXed to PC
            i_branch     : in std_logic;                       -- indicator to branch from ALU based on operand comparison
            i_branch_chk : in std_logic;                       -- indicator to branch from Control Module based on instruction read
            i_IMM_EXT    : in std_logic_vector(31 downto 0);   -- 32 bit extended immediate, used for branch instructions
            i_RS_DATA    : in std_logic_vector(31 downto 0);   -- Contents of second source register, used for jr, PC = R[Rs]
            i_J_ADDR     : in std_logic_vector(25 downto 0);   -- adress field of J-type instruction, used for jump instructions to update PC
            o_PC         : out std_logic_vector(31 downto 0);  -- Program Counter, address used to access instruction memory on top level
            o_PC_4       : out std_logic_vector(31 downto 0)); -- Program Counter + 4, wired to destination register write data for jal instruction, so $ra updates
    end component;



    -- Input signals of tested module
    signal s_CLK, s_PC_RST, s_branch, s_branch_chk : std_logic:= '0';
    signal s_PC_SEL  : std_logic_vector (1 downto 0) := "00";
    signal s_IMM_EXT, s_RS_DATA: std_logic_vector (31 downto 0):= X"00000000";
    signal s_J_ADDR : std_logic_vector (25 downto 0):= "00000000000000000000000000";


    -- Output signals of tested module
    signal s_PC, s_PC_4 : std_logic_vector (31 downto 0);

begin

    DUT0 : fetch
    port map(
        i_CLK        => s_CLK,
        i_PC_RST     => s_PC_RST,
        i_PC_SEL     => s_PC_SEL,
        i_branch     => s_branch,
        i_branch_chk => s_branch_chk,
        i_IMM_EXT    => s_IMM_EXT,
        i_RS_DATA    => s_RS_DATA,
        i_J_ADDR     => s_J_ADDR,
        o_PC         => s_PC,
        o_PC_4       => s_PC_4
    );

    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;  

    -- Testbench process  
    P_DUT0 : process
    begin
        wait for cCLK_PER;
        s_PC_RST  <= '1';
        wait for cCLK_PER;
        s_PC_SEL <= "11";
        s_PC_RST  <= '0';
        s_IMM_EXT <= x"00001000";
        s_branch <= '1';
        wait for cCLK_PER;
        s_PC_RST  <= '0';
        s_branch <= '1';
        s_branch_chk <= '1';
        wait for cCLK_PER;
        s_PC_RST  <= '0';
        s_branch <= '1';
        s_branch_chk <= '0';
        wait for cCLK_PER;
        s_RS_DATA <= x"00402000";
        wait for cCLK_PER;
        s_RS_DATA <= x"00402000";
        s_PC_SEL <= "10";
        wait for cCLK_PER;
        s_RS_DATA <= x"00402000";
        s_PC_SEL <= "00";
        wait for cCLK_PER;
        s_J_ADDR<=  "00000000000100000000000000";
        wait for cCLK_PER;
        s_J_ADDR<=  "00000000000100000000000000";
        s_PC_SEL <= "01";
        wait for cCLK_PER;
        s_RS_DATA <= x"f0402000";
        s_PC_SEL <= "10";
        wait for cCLK_PER;
        s_J_ADDR<=  "00000000000100000000000000";
        s_PC_SEL <= "01";
        -- TO CHECK
        wait;
        
    end process;

end mixed;