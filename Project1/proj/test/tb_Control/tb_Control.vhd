-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_Control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level Control file in our Single Cycle MIPS Processor
--
--
-- NOTES:
-- Created 2/27/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Control is
    generic (gCLK_HPER : time := 10 ns);
end tb_Control;

architecture mixed of tb_Control is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component control is
        port (
            i_OPCODE            : in std_logic_vector(5 downto 0);   --Opcode, instruction[31:26]
            i_FUNCT             : in std_logic_vector(5 downto 0);   --Function of R-type instruction
            i_RT_ADDR           : in std_logic_vector(4 downto 0);   --RT address of instruction
            o_halt              : out std_logic;                     --If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
            o_extend_nZero_Sign : out std_logic;                     -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
            o_ALUSrc            : out std_logic;                     -- If 0, use register source. If 1, use immediate
            o_overflow_chk      : out std_logic;                     -- If 1, enable check for overflow
            o_branch_chk        : out std_logic;                     -- If 1, enable check for branch
            o_reg_DST_ADDR_SEL  : out std_logic_vector(1 downto 0);  --MUX select for source of destination register address
            o_reg_DST_DATA_SEL  : out std_logic_vector(1 downto 0);  --MUX select for source of destination register data
            o_PC_SEL            : out std_logic_vector(1 downto 0);  -- Fetch Control, MUX select for source of PC increment
            o_reg_WE            : out std_logic;                     -- if 1, write to destiantion register 
            o_mem_WE            : out std_logic;                     -- if 1, write to memory
            o_nAdd_Sub          : out std_logic;                     -- ALU Control, 0 if add, 1 if sub
            o_shift_SEL         : out std_logic_vector(1 downto 0);  -- ALU Control, MUX select for shift output
            o_branch_SEL        : out std_logic_vector(2 downto 0);  -- ALU Control, MUX select for branch indicator output
            o_logic_SEL         : out std_logic_vector(1 downto 0);  -- ALU Control, MUX select for logic output
            o_out_SEL           : out std_logic_vector(1 downto 0)); -- ALU Control, MUX select for source submodule output
    end component;

    -- Input signals of tested module
    signal s_OPCODE : std_logic_vector (5 downto 0) := "000000"; --OPCODE
    signal s_FUNCT : std_logic_vector (5 downto 0) := "000000"; --FUNCTION
    signal s_RT_ADDR : std_logic_vector (4 downto 0) := "00000"; --RT for branching functions

    -- Output signals of tested module
    signal s_halt, s_extend_nZero_Sign, s_ALUSrc, s_overflow_chk, s_branch_chk, s_reg_WE, s_mem_WE, s_nAdd_Sub : std_logic;
    signal s_reg_DST_ADDR_SEL, s_reg_DST_DATA_SEL, s_PC_SEL, s_shift_SEL, s_logic_SEL, s_out_SEL : std_logic_vector (1 downto 0);
    signal s_branch_SEL : std_logic_vector (2 downto 0);

    -- Test signals
    -- Output signals of tested module
    signal c_halt, c_extend_nZero_Sign, c_ALUSrc, c_overflow_chk, c_branch_chk, c_reg_WE, c_mem_WE, c_nAdd_Sub : std_logic := '0';
    signal c_reg_DST_ADDR_SEL, c_reg_DST_DATA_SEL, c_PC_SEL, c_shift_SEL, c_logic_SEL, c_out_SEL : std_logic_vector (1 downto 0) := "00";
    signal c_branch_SEL : std_logic_vector (2 downto 0) := "000";

    signal e_halt, e_extend_nZero_Sign, e_ALUSrc, e_overflow_chk, e_branch_chk, e_reg_WE, e_mem_WE, e_nAdd_Sub, e_reg_DST_ADDR_SEL, e_reg_DST_DATA_SEL, e_PC_SEL, e_shift_SEL, e_logic_SEL, e_out_SEL, e_branch_SEL : std_logic := '0';

    signal s_error : std_logic := '0';
    signal s_OP_ASCII : std_logic_vector(47 downto 0);
begin

    DUT0 : control
    port map(
        i_OPCODE            => s_OPCODE,            --Opcode, instruction[31:26]
        i_FUNCT             => s_FUNCT,             --Function of R-type instruction
        i_RT_ADDR           => s_RT_ADDR,           --RT address of instruction
        o_halt              => s_halt,              --If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
        o_extend_nZero_Sign => s_extend_nZero_Sign, -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
        o_ALUSrc            => s_ALUSrc,            -- If 0, use register source. If 1, use immediate
        o_overflow_chk      => s_overflow_chk,      -- If 1, enable check for overflow
        o_branch_chk        => s_branch_chk,        -- If 1, enable check for branch
        o_reg_DST_ADDR_SEL  => s_reg_DST_ADDR_SEL,  --MUX select for source of destination register address
        o_reg_DST_DATA_SEL  => s_reg_DST_DATA_SEL,  --MUX select for source of destination register data
        o_PC_SEL            => s_PC_SEL,            -- Fetch Control, MUX select for source of PC increment
        o_reg_WE            => s_reg_WE,            -- if 1, write to destiantion register 
        o_mem_WE            => s_mem_WE,            -- if 1, write to memory
        o_nAdd_Sub          => s_nAdd_Sub,          -- ALU Control, 0 if add, 1 if sub
        o_shift_SEL         => s_shift_SEL,         -- ALU Control, MUX select for shift output
        o_branch_SEL        => s_branch_SEL,        -- ALU Control, MUX select for branch indicator output
        o_logic_SEL         => s_logic_SEL,         -- ALU Control, MUX select for logic output
        o_out_SEL           => s_out_SEL            -- ALU Control, MUX select for source submodule output
    );

    P_RD_CHK : process
    begin

        wait for gCLK_HPER;

        if ((e_halt = '1') and(s_halt /= c_halt)) then
            s_error <= '1';
        elsif ((e_extend_nZero_Sign = '1') and(s_extend_nZero_Sign /= s_extend_nZero_Sign)) then
            s_error <= '1';
        elsif ((e_ALUSrc = '1') and(s_ALUSrc /= c_ALUSrc)) then
            s_error <= '1';
        elsif ((e_overflow_chk = '1') and(s_overflow_chk /= c_overflow_chk)) then
            s_error <= '1';
        elsif ((e_branch_chk = '1') and(s_branch_chk /= c_branch_chk)) then
            s_error <= '1';
        elsif ((e_reg_WE = '1') and(s_reg_WE /= c_reg_WE)) then
            s_error <= '1';
        elsif ((e_mem_WE = '1') and(s_mem_WE /= c_mem_WE)) then
            s_error <= '1';
        elsif ((e_nAdd_Sub = '1') and(s_nAdd_Sub /= c_nAdd_Sub)) then
            s_error <= '1';
        elsif ((e_reg_DST_ADDR_SEL = '1') and(s_reg_DST_ADDR_SEL /= c_reg_DST_ADDR_SEL)) then
            s_error <= '1';
        elsif ((e_reg_DST_DATA_SEL = '1') and(s_reg_DST_DATA_SEL /= c_reg_DST_DATA_SEL)) then
            s_error <= '1';
        elsif ((e_PC_SEL = '1') and(s_PC_SEL /= c_PC_SEL)) then
            s_error <= '1';
        elsif ((e_shift_SEL = '1') and(s_shift_SEL /= c_shift_SEL)) then
            s_error <= '1';
        elsif ((e_logic_SEL = '1') and(s_logic_SEL /= c_logic_SEL)) then
            s_error <= '1';
        elsif ((e_out_SEL = '1') and(s_out_SEL /= c_out_SEL)) then
            s_error <= '1';
        elsif ((e_branch_SEL = '1') and(s_branch_SEL /= c_branch_SEL)) then
            s_error <= '1';
        else
            s_error <= '0';
        end if;
    end process;
    -- Testbench process  
    P_DUT0 : process
    begin
        wait for cCLK_PER;
        --add 
        s_OP_ASCII <= X"414444202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '1';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --addi 
        s_OP_ASCII <= X"414444492020";
        s_OPCODE <= "001000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '1';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --addiu 
        s_OP_ASCII <= X"414444495520";
        s_OPCODE <= "001001";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --addu 
        s_OP_ASCII <= X"414444205520";
        s_OPCODE <= "000000";
        s_FUNCT <= "100001";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --and
        s_OP_ASCII <= X"414e44202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100100";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --andi
        s_OP_ASCII <= X"414e44492020";
        s_OPCODE <= "001100";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --lui
        s_OP_ASCII <= X"4c5549202020";
        s_OPCODE <= "001111";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "10";
        e_shift_SEL <= '1';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "01";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --lw
        s_OP_ASCII <= X"4c5720202020";
        s_OPCODE <= "100011";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "01";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00"; 
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "10";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --nor
        s_OP_ASCII <= X"4e4f52202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100111";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "01";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --xor
        s_OP_ASCII <= X"584f52202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100110";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "10";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --xori
        s_OP_ASCII <= X"584f52492020";
        s_OPCODE <= "001110";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "10";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --or
        s_OP_ASCII <= X"4f5220202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100101";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "11";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --ori
        s_OP_ASCII <= X"4f5249202020";
        s_OPCODE <= "001101";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "11";
        e_logic_SEL <= '1';
        c_out_SEL <= "10";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --slt
        s_OP_ASCII <= X"534c54202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "101010";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "11";
        e_logic_SEL <= '0';
        c_out_SEL <= "11";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --slti
        s_OP_ASCII <= X"534c54492020";
        s_OPCODE <= "001010";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "11";
        e_logic_SEL <= '0';
        c_out_SEL <= "11";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --sll
        s_OP_ASCII <= X"534c4c202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "000000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '1';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "01";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --srl
        s_OP_ASCII <= X"53524c202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "000010";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "01";
        e_shift_SEL <= '1';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "01";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --sra
        s_OP_ASCII <= X"535241202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "000011";
        
        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "11";
        e_shift_SEL <= '1';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "01";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --sw
        s_OP_ASCII <= X"535720202020";
        s_OPCODE <= "101011";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '1';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "01";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "01";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '1';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '0';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "11";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --sub
        s_OP_ASCII <= X"535542202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100010";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '0';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '1';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --subu
        s_OP_ASCII <= X"535542552020";
        s_OPCODE <= "000000";
        s_FUNCT <= "100011";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '1';
        wait for cCLK_PER;

        --beq
        s_OP_ASCII <= X"424551202020";
        s_OPCODE <= "000100";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="000";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bne
        s_OP_ASCII <= X"424e45202020";
        s_OPCODE <= "000101";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '1';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="001";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --j
        s_OP_ASCII <= X"4a2020202020";
        s_OPCODE <= "000010";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '0';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "00";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "00";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "01";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="001";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --jal
        s_OP_ASCII <= X"4a414c202020";
        s_OPCODE <= "000011";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '0';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "01";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="001";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --jr
        s_OP_ASCII <= X"4a5220202020";
        s_OPCODE <= "000000";
        s_FUNCT <= "001000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '0';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "10";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="001";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bgez
        s_OP_ASCII <= X"4247455a2020";
        s_OPCODE <= "000001";
        s_RT_ADDR <= "00001";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="010";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bgezal
        s_OP_ASCII <= X"4247455a414c";
        s_OPCODE <= "000001";
        s_RT_ADDR <= "10001";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="011";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bgtz
        s_OP_ASCII <= X"4247545a2020";
        s_OPCODE <= "000111";
        s_RT_ADDR <= "00000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="100";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --blez
        s_OP_ASCII <= X"424c455a2020";
        s_OPCODE <= "000110";
        s_RT_ADDR <= "00000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="101";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bltzal
        s_OP_ASCII <= X"424c545a414c";
        s_OPCODE <= "000001";
        s_RT_ADDR <= "10000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '1';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '1';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '1';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="110";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --bltz
        s_OP_ASCII <= X"424c545a2020";
        s_OPCODE <= "000001";
        s_RT_ADDR <= "00000";

        c_halt <= '0';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '1';
        c_ALUSrc <= '0';
        e_ALUSrc <= '1';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '1';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "11";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="111";
        e_branch_SEL <= '1';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        --halt
        s_OP_ASCII <= X"48414c542020";
        s_OPCODE <= "010100";

        c_halt <= '1';
        e_halt <= '1';
        c_extend_nZero_Sign <= '1';
        e_extend_nZero_Sign <= '0';
        c_ALUSrc <= '0';
        e_ALUSrc <= '0';
        c_overflow_chk <= '0';
        e_overflow_chk <= '1';
        c_branch_chk <= '0';
        e_branch_chk <= '1';
        c_reg_DST_ADDR_SEL <= "10";
        e_reg_DST_ADDR_SEL <= '0';
        c_reg_DST_DATA_SEL <= "10";
        e_reg_DST_DATA_SEL <= '0';
        c_PC_SEL <= "00";
        e_PC_SEL<= '1';
        c_reg_WE <= '0';
        e_reg_WE <= '1';
        c_mem_WE <= '0';
        e_mem_WE <= '1';
        c_nAdd_Sub <= '1';
        e_nAdd_Sub <= '0';
        c_shift_SEL <= "00";
        e_shift_SEL <= '0';
        c_branch_SEL <="111";
        e_branch_SEL <= '0';
        c_logic_SEL <= "00";
        e_logic_SEL <= '0';
        c_out_SEL <= "00";
        e_out_SEL <= '0';
        wait for cCLK_PER;

        wait for cCLK_PER;
    end process;

end mixed;