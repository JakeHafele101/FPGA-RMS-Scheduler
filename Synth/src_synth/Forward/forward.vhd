-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- hazardDetetion.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the fowarding module
-- 
-- Created 4/6/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity forward is
    port (
        i_EX_OPCODE          : in std_logic_vector(5 downto 0);  -- EX Opcode, instruction[31:26]
        i_EX_FUNCT           : in std_logic_vector(5 downto 0);  -- Function of R-type instruction
        i_EX_RS_ADDR         : in std_logic_vector(4 downto 0);  -- RS address of instruction
        i_EX_RT_ADDR         : in std_logic_vector(4 downto 0);  -- RT address of instruction
        i_DMEM_RegWrAddr     : in std_logic_vector(4 downto 0);  -- destination address of instruction in Execute
        i_WB_RegWrAddr       : in std_logic_vector(4 downto 0);  -- destination address of instruction in Data Memory
        i_DMEM_RegWr         : in std_logic;                     -- destination write enable of instruction in Execute
        i_WB_RegWr           : in std_logic;                     -- destination write enable of instruction in Data memory
        o_EX_RS_DATA_FWD_SEL : out std_logic_vector(1 downto 0); -- Active High (if one output 0 from buffer)
        o_EX_RT_DATA_FWD_SEL : out std_logic_vector(1 downto 0);
        o_DMEM_DATA_FWD_SEL  : out std_logic_vector(1 downto 0);
        o_LW_HAZARD_CHK      : out std_logic
    );
end forward;

architecture dataflow of forward is
    -- s_fwd_check is 2 bits
    -- s_fwd_check(2): forward to DMEM Data in DMEM stage (SW only)
    -- s_fwd_check(1): forward to RS ALU input in EX stage
    -- s_fwd_check(0): forward to RT ALU input in EX stage
    signal s_fwd_check : std_logic_vector(2 downto 0);

    -- 1 if RegWrAddr is 0 in respective stage, 0 otherwise
    signal s_DMEM_RegWrAddr_Zero, s_WB_RegWrAddr_Zero : std_logic;

    -- interal signal to XOR, used for equal comparisons
    signal s_DMEM_RD_EX_RS_XOR, s_DMEM_RD_EX_RT_XOR : std_logic_vector(4 downto 0);
    signal s_WB_RD_EX_RS_XOR, s_WB_RD_EX_RT_XOR : std_logic_vector(4 downto 0);

    -- 1 if RD address and RS/RT address equal, 0 otherwise
    signal s_DMEM_RD_EX_RS_EQ, s_DMEM_RD_EX_RT_EQ : std_logic;
    signal s_WB_RD_EX_RS_EQ, s_WB_RD_EX_RT_EQ : std_logic;

    signal s_DMEM_RS_FWD, s_DMEM_RT_FWD : std_logic;
    signal s_WB_RS_FWD, s_WB_RT_FWD : std_logic;
    signal s_DMEM_DMEM_DATA_FWD,s_WB_DMEM_DATA_FWD : std_logic;

begin

    -- Don't cares from control table are 0's here
    process (i_EX_OPCODE, i_EX_FUNCT) is
    begin
        case i_EX_OPCODE is
            when "000000" => --If opcode 0, R-type
                case i_EX_FUNCT is
                    when "100000" => s_fwd_check <= "011"; --add
                    when "100001" => s_fwd_check <= "011"; --addu
                    when "100100" => s_fwd_check <= "011"; --and
                    when "100111" => s_fwd_check <= "011"; --nor
                    when "100110" => s_fwd_check <= "011"; --xor
                    when "100101" => s_fwd_check <= "011"; --or
                    when "101010" => s_fwd_check <= "011"; --slt
                    when "000000" => s_fwd_check <= "001"; --sll
                    when "000010" => s_fwd_check <= "001"; --srl
                    when "000011" => s_fwd_check <= "001"; --sra
                    when "100010" => s_fwd_check <= "011"; --sub
                    when "100011" => s_fwd_check <= "011"; --subu
                    when "001000" => s_fwd_check <= "000"; --jr
                    when others => s_fwd_check <= "000"; -- default so no explosion

                end case;

            when "000001" => s_fwd_check <= "001";--bgez, bgezal, bltzal, bltz
                -- Every other instruction can be read with just opcode!
            when "001000" => s_fwd_check <= "010"; --addi
            when "001001" => s_fwd_check <= "010"; --addiu
            when "001100" => s_fwd_check <= "010"; --andi 
            when "001111" => s_fwd_check <= "000"; --lui
            when "100011" => s_fwd_check <= "010"; --lw, forward RS for address
            when "001110" => s_fwd_check <= "010"; --xori
            when "001101" => s_fwd_check <= "010"; --ori
            when "001010" => s_fwd_check <= "010"; --slti
            when "101011" => s_fwd_check <= "110"; --sw forward RS for address, RT for dmem data
            when "000100" => s_fwd_check <= "000"; --beq  
            when "000101" => s_fwd_check <= "000"; --bne  
            when "000010" => s_fwd_check <= "000"; --j    
            when "000011" => s_fwd_check <= "000"; --jal
            when "000111" => s_fwd_check <= "000"; --bgtz 
            when "000110" => s_fwd_check <= "000"; --blez 
            when "010100" => s_fwd_check <= "000"; --halt
            when others => s_fwd_check <= "000"; -- default so no explosion
        end case;
    end process;

    -- Check if DMEM/WB Rd address is 0
    s_DMEM_RegWrAddr_Zero <= '1' when i_DMEM_RegWrAddr = "00000" else
        '0';
    s_WB_RegWrAddr_Zero <= '1' when i_WB_RegWrAddr = "00000" else
        '0';

    -- Check if DMEM/WB RD Address equal to EX RS/RT address
    s_DMEM_RD_EX_RS_XOR <= i_DMEM_RegWrAddr xor i_EX_RS_ADDR;
    s_DMEM_RD_EX_RT_XOR <= i_DMEM_RegWrAddr xor i_EX_RT_ADDR;
    s_WB_RD_EX_RS_XOR <= i_WB_RegWrAddr xor i_EX_RS_ADDR;
    s_WB_RD_EX_RT_XOR <= i_WB_RegWrAddr xor i_EX_RT_ADDR;

    s_DMEM_RD_EX_RS_EQ <= '1' when s_DMEM_RD_EX_RS_XOR = "00000" else
        '0';
    s_DMEM_RD_EX_RT_EQ <= '1' when s_DMEM_RD_EX_RT_XOR = "00000" else
        '0';
    s_WB_RD_EX_RS_EQ <= '1' when s_WB_RD_EX_RS_XOR = "00000" else
        '0';
    s_WB_RD_EX_RT_EQ <= '1' when s_WB_RD_EX_RT_XOR = "00000" else
        '0';

    -- Determines if FWD possible
    s_DMEM_RS_FWD <= i_DMEM_RegWr and (not s_DMEM_RegWrAddr_Zero) and s_DMEM_RD_EX_RS_EQ and s_fwd_check(1);
    s_DMEM_RT_FWD <= i_DMEM_RegWr and (not s_DMEM_RegWrAddr_Zero) and s_DMEM_RD_EX_RT_EQ and s_fwd_check(0);
    s_WB_RS_FWD <= i_WB_RegWr and (not s_WB_RegWrAddr_Zero) and s_WB_RD_EX_RS_EQ and s_fwd_check(1) and (not s_DMEM_RS_FWD);
    s_WB_RT_FWD <= i_WB_RegWr and (not s_WB_RegWrAddr_Zero) and s_WB_RD_EX_RT_EQ and s_fwd_check(0) and (not s_DMEM_RT_FWD);

    s_DMEM_DMEM_DATA_FWD <= i_DMEM_RegWr and (not s_DMEM_RegWrAddr_Zero) and s_DMEM_RD_EX_RT_EQ and s_fwd_check(2);
    s_WB_DMEM_DATA_FWD <= i_WB_RegWr and (not s_WB_RegWrAddr_Zero) and s_WB_RD_EX_RT_EQ and s_fwd_check(2) and (not s_DMEM_DMEM_DATA_FWD);

    -- Select line for FWD muxes in EX stage as follows:
    -- 00: no forwarding
    -- 01: forward from WB stage
    -- 10: forward from DMEM stage
    -- 11: Not possible
    o_EX_RS_DATA_FWD_SEL <= s_DMEM_RS_FWD & s_WB_RS_FWD;
    o_EX_RT_DATA_FWD_SEL <= s_DMEM_RT_FWD & s_WB_RT_FWD;
    o_DMEM_DATA_FWD_SEL  <= s_DMEM_DMEM_DATA_FWD & s_WB_DMEM_DATA_FWD;
    
    -- LW Hazard Stall check
    o_LW_HAZARD_CHK <= '1' when i_EX_OPCODE = "100011" else
        '0';

end dataflow;