-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the control module, 
-- which takes a 6 bit input opcode and outputs multiple control units 
-- for the ALU Control module, Multiplexers, and write enables
-- 
-- Created 2/23/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity control is
    port (
        i_OPCODE            : in std_logic_vector(5 downto 0);  --Opcode, instruction[31:26]
        i_FUNCT             : in std_logic_vector(5 downto 0);  --Function of R-type instruction
        i_RT_ADDR           : in std_logic_vector(4 downto 0);  --RT address of instruction
        o_halt              : out std_logic;                    --If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
        o_extend_nZero_Sign : out std_logic;                    -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
        o_ALUSrc            : out std_logic;                    -- If 0, use register source. If 1, use immediate
        o_overflow_chk      : out std_logic;                    -- If 1, enable check for overflow
        o_branch_chk        : out std_logic;                    -- If 1, enable check for branch
        o_reg_DST_ADDR_SEL  : out std_logic_vector(1 downto 0); --MUX select for source of destination register address
        o_reg_DST_DATA_SEL  : out std_logic_vector(1 downto 0); --MUX select for source of destination register data
        o_PC_SEL            : out std_logic_vector(1 downto 0); -- Fetch Control, MUX select for source of PC increment
        o_reg_WE            : out std_logic;                    -- if 1, write to destiantion register 
        o_mem_WE            : out std_logic;                    -- if 1, write to memory
        o_nAdd_Sub          : out std_logic;                    -- ALU Control, 0 if add, 1 if sub
        o_shift_SEL         : out std_logic_vector(1 downto 0); -- ALU Control, MUX select for shift output
        o_branch_SEL        : out std_logic_vector(2 downto 0); -- ALU Control, MUX select for branch indicator output
        o_logic_SEL         : out std_logic_vector(1 downto 0); -- ALU Control, MUX select for logic output
        o_out_SEL           : out std_logic_vector(1 downto 0) -- ALU Control, MUX select for source submodule output
    );
end control;

architecture dataflow of control is

    -- Control bits are as follows:
    -- 22:    halt
    -- 21:    extend_nZero_Sign
    -- 20:    ALUSrc
    -- 19:    overflow_chk
    -- 18:    branch_chk
    -- 17-16: reg_DST_ADDR_SEL
    -- 15-14: reg_DST_DATA_SEL       *
    -- 13-12: PC_SEL     *
    -- 11:    reg_WE
    -- 10:    mem_WE
    -- 9:     nAdd_Sub
    -- 8-7:   shift_SEL
    -- 6-4:   branch_SEL
    -- 3-2:   logic_SEL
    -- 1-0:   out_SEL
    signal s_CONTROLS : std_logic_vector(22 downto 0); --Total control assignment, to be split up to output after case statement

begin

    -- Don't cares from control table are 0's here
    process (i_OPCODE, i_FUNCT, i_RT_ADDR) is
    begin
        case i_OPCODE is
            when "000000" => --If opcode 0, R-type
                case i_FUNCT is
                    when "100000" => s_CONTROLS <= "00010000000100000000000"; --add
                    when "100001" => s_CONTROLS <= "00000000000100000000000"; --addu
                    when "100100" => s_CONTROLS <= "00000000000100000000010"; --and
                    when "100111" => s_CONTROLS <= "00000000000100000000110"; --nor
                    when "100110" => s_CONTROLS <= "00000000000100000001010"; --xor
                    when "100101" => s_CONTROLS <= "00000000000100000001110"; --or
                    when "101010" => s_CONTROLS <= "00000000000101000000011"; --slt
                    when "000000" => s_CONTROLS <= "00000000000100000000001"; --sll
                    when "000010" => s_CONTROLS <= "00000000000100010000001"; --srl
                    when "000011" => s_CONTROLS <= "00000000000100110000001"; --sra
                    when "100010" => s_CONTROLS <= "00010000000101000000000"; --sub
                    when "100011" => s_CONTROLS <= "00000000000101000000000"; --subu
                    when "001000" => s_CONTROLS <= "00000000010000000000000"; --jr

                    when others => s_CONTROLS <= "00000000000000000000000"; -- default so no explosion
                end case;

            when "000001" => --bgez, bgezal, bltzal, bltz
                case i_RT_ADDR is
                    when "00001" => s_CONTROLS <= "01001000011000000100000"; --bgez
                    when "10001" => s_CONTROLS <= "01001101011100000110000"; --bgezal
                    when "10000" => s_CONTROLS <= "01001101011100001100000"; --bltzal
                    when "00000" => s_CONTROLS <= "01001000011000001110000"; --bltz

                    when others => s_CONTROLS <= "00000000000000000000000"; -- default so no explosion
                end case;

                -- Every other instruction can be read with just opcode!
            when "001000" => s_CONTROLS <= "01110010000100000000000"; --addi
            when "001001" => s_CONTROLS <= "01100010000100000000000"; --addiu
            when "001100" => s_CONTROLS <= "00100010000100000000010"; --andi
            when "001111" => s_CONTROLS <= "00100010000100100000001"; --lui
            when "100011" => s_CONTROLS <= "01100010100100000000000"; --lw
            when "001110" => s_CONTROLS <= "00100010000100000001010"; --xori
            when "001101" => s_CONTROLS <= "00100010000100000001110"; --ori
            when "001010" => s_CONTROLS <= "01100010000101000000011"; --slti
            when "101011" => s_CONTROLS <= "01100000000010000000000"; --sw
            when "000100" => s_CONTROLS <= "01001000011001000000000"; --beq
            when "000101" => s_CONTROLS <= "01001000011001000010000"; --bne
            when "000010" => s_CONTROLS <= "00000000001000000000000"; --j
            when "000011" => s_CONTROLS <= "00000101001100000000000"; --jal
            when "000111" => s_CONTROLS <= "01001000011000001000000"; --bgtz
            when "000110" => s_CONTROLS <= "01001000011000001010000"; --blez
            when "010100" => s_CONTROLS <= "10000000000000000000000"; --halt


            when others => s_CONTROLS <= "00000000000000000000000"; -- default so no explosion
        end case;
    end process;

    -- Output port assignment
    o_halt <= s_CONTROLS(22);
    o_extend_nZero_Sign <= s_CONTROLS(21);
    o_ALUSrc <= s_CONTROLS(20);
    o_overflow_chk <= s_CONTROLS(19);
    o_branch_chk <= s_CONTROLS(18);
    o_reg_DST_ADDR_SEL <= s_CONTROLS(17 downto 16);
    o_reg_DST_DATA_SEL <= s_CONTROLS(15 downto 14);
    o_PC_SEL <= s_CONTROLS(13 downto 12);
    o_reg_WE <= s_CONTROLS(11);
    o_mem_WE <= s_CONTROLS(10);
    o_nAdd_Sub <= s_CONTROLS(9);
    o_shift_SEL <= s_CONTROLS(8 downto 7);
    o_branch_SEL <= s_CONTROLS(6 downto 4);
    o_logic_SEL <= s_CONTROLS(3 downto 2);
    o_out_SEL <= s_CONTROLS(1 downto 0);

end dataflow;