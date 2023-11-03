-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- hazardDetetion.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the hararddetection module, 
-- which takes a 6 bit input opcode and fuction, and register addreses and outputs 
--multiple controls for flushing and stalling
-- 
-- Created 3/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity hazardDetection is
    port (
        i_OPCODE         : in std_logic_vector(5 downto 0); -- Opcode, instruction[31:26]
        i_FUNCT          : in std_logic_vector(5 downto 0); -- Function of R-type instruction
        i_ID_RS_ADDR     : in std_logic_vector(4 downto 0); -- RS address of instruction
        i_ID_RT_ADDR     : in std_logic_vector(4 downto 0); -- RT address of instruction
        i_EX_RegWrAddr   : in std_logic_vector(4 downto 0); -- destination address of instruction in Execute
        i_DMEM_RegWrAddr : in std_logic_vector(4 downto 0); -- destination address of instruction in Data Memory
        i_EX_RegWr       : in std_logic_vector(0 downto 0); -- destination write enable of instruction in Execute
        i_DMEM_RegWr     : in std_logic_vector(0 downto 0); -- destination write enable of instruction in Data memory
        i_branch         : in std_logic_vector(0 downto 0); --Final branch determination from branch module
        i_branch_chk     : in std_logic_vector(0 downto 0); --Chk condition from control if branch module
        i_LW_STALL       : in std_logic;                    --Chk condition from forward module to see if lw data hazard (may stall once)
        i_EX_halt        : in std_logic;
        i_DMEM_halt      : in std_logic;
        o_IF_ID_STALL    : out std_logic; -- Active High (if one output 0 from buffer)
        o_ID_EX_STALL    : out std_logic;
        o_EX_DMEM_STALL  : out std_logic;
        o_DMEM_WB_STALL  : out std_logic;
        o_IF_ID_FLUSH    : out std_logic;
        o_ID_EX_FLUSH    : out std_logic;
        o_EX_DMEM_FLUSH  : out std_logic;
        o_DMEM_WB_FLUSH  : out std_logic;
        o_PC_STALL       : out std_logic);
end hazardDetection;

architecture dataflow of hazardDetection is
    -- s_check is 3 bits
    -- s_check(3): forwarding, skip stall if 1
    -- s_check(2): control hazard
    -- s_check(1): hazard on rt
    -- s_check(0): hazard on rs

    signal s_branch_final : std_logic;

    signal s_check : std_logic_vector(3 downto 0);

    signal s_EX_rsXOR : std_logic_vector(4 downto 0);
    signal s_EX_rtXOR : std_logic_vector(4 downto 0);
    signal s_DMEM_rsXOR : std_logic_vector(4 downto 0);
    signal s_DMEM_rtXOR : std_logic_vector(4 downto 0);

    signal s_EX_rsAnd_MUX : std_logic;
    signal s_EX_rtAnd_MUX : std_logic;
    signal s_DMEM_rsAnd_MUX : std_logic;
    signal s_DMEM_rtAnd_MUX : std_logic;

    signal s_EX_rsAnd_EN : std_logic;
    signal s_EX_rtAnd_EN : std_logic;
    signal s_DMEM_rsAnd_EN : std_logic;
    signal s_DMEM_rtAnd_EN : std_logic;

    signal s_rs_Hazard : std_logic;
    signal s_rt_Hazard : std_logic;
    signal s_rs_rt_Hazard : std_logic;

    signal s_data_Hazard : std_logic;
    signal s_control_Hazard : std_logic;

    signal s_data_hazard_and_lw : std_logic; --FIXME
begin

    -- Don't cares from control table are 0's here
    process (i_OPCODE, i_FUNCT) is
    begin
        case i_OPCODE is
            when "000000" => --If opcode 0, R-type
                case i_FUNCT is
                    when "100000" => s_check <= "1011"; --add
                    when "100001" => s_check <= "1011"; --addu
                    when "100100" => s_check <= "1011"; --and
                    when "100111" => s_check <= "1011"; --nor
                    when "100110" => s_check <= "1011"; --xor
                    when "100101" => s_check <= "1011"; --or
                    when "101010" => s_check <= "1011"; --slt
                    when "000000" => s_check <= "1010"; --sll
                    when "000010" => s_check <= "1010"; --srl
                    when "000011" => s_check <= "1010"; --sra
                    when "100010" => s_check <= "1011"; --sub
                    when "100011" => s_check <= "1011"; --subu
                    when "001000" => s_check <= "0101"; --jr --Not forwarding, NEED TO STALL
                    when others => s_check <= "0000"; -- default so no explosion

                end case;

            when "000001" => s_check <= "0001";--bgez, bgezal, bltzal, bltz
                -- Every other instruction can be read with just opcode!
            when "001000" => s_check <= "1001"; --addi
            when "001001" => s_check <= "1001"; --addiu
            when "001100" => s_check <= "1001"; --andi
            when "001111" => s_check <= "1000"; --lui
            when "100011" => s_check <= "1001"; --lw
            when "001110" => s_check <= "1001"; --xori
            when "001101" => s_check <= "1001"; --ori
            when "001010" => s_check <= "1001"; --slti
            when "101011" => s_check <= "1011"; --sw
            when "000100" => s_check <= "0011"; --beq
            when "000101" => s_check <= "0011"; --bne
            when "000010" => s_check <= "0100"; --j
            when "000011" => s_check <= "0100"; --jal
            when "000111" => s_check <= "0001"; --bgtz
            when "000110" => s_check <= "0001"; --blez
            when "010100" => s_check <= "0000"; --halt
            when others => s_check <= "0000"; -- default so no explosion
        end case;
    end process;

    s_branch_final <= i_branch(0) and i_branch_chk(0);

    s_EX_rsXOR <= i_ID_RS_ADDR xor i_EX_RegWrAddr; -- IF "00000" then equal
    s_EX_rtXOR <= i_ID_RT_ADDR xor i_EX_RegWrAddr;
    s_DMEM_rsXOR <= i_ID_RS_ADDR xor i_DMEM_RegWrAddr;
    s_DMEM_rtXOR <= i_ID_RT_ADDR xor i_DMEM_RegWrAddr;

    --sets equals to a single std_logic variable and ignores cases with the zero register
    s_EX_rsAnd_MUX <= '1' when (s_EX_rsXOR = "00000") and (i_ID_RS_ADDR /= "00000")else
        '0';
    s_EX_rtAnd_MUX <= '1' when (s_EX_rtXOR = "00000") and (i_ID_RT_ADDR /= "00000")else
        '0';
    s_DMEM_rsAnd_MUX <= '1' when (s_DMEM_rsXOR = "00000") and (i_ID_RS_ADDR /= "00000") else
        '0';
    s_DMEM_rtAnd_MUX <= '1' when (s_DMEM_rtXOR = "00000") and (i_ID_RT_ADDR /= "00000")else
        '0';

    --Checks if the register will be written to
    s_EX_rsAnd_EN <= s_EX_rsAnd_MUX and i_EX_RegWr(0);
    s_EX_rtAnd_EN <= s_EX_rtAnd_MUX and i_EX_RegWr(0);
    s_DMEM_rsAnd_EN <= s_DMEM_rsAnd_MUX and i_DMEM_RegWr(0);
    s_DMEM_rtAnd_EN <= s_DMEM_rtAnd_MUX and i_DMEM_RegWr(0);

    --gets data rs hazards combined
    s_rs_Hazard <= s_EX_rsAnd_EN or s_DMEM_rsAnd_EN;
    s_rt_Hazard <= s_EX_rtAnd_EN or s_DMEM_rtAnd_EN;
    --gets data rs and rt hazards combined
    s_rs_rt_Hazard <= s_EX_rsAnd_EN or s_DMEM_rsAnd_EN or s_EX_rtAnd_EN or s_DMEM_rtAnd_EN;

    -- Compares output hazard based on current hazard case
    with s_check(1 downto 0) select
    s_data_Hazard <= '0' when "00", --HALT
        s_rs_Hazard when "01", --just rs hazard check
        s_rt_Hazard when "10", --just rt hazard check
        s_rs_rt_Hazard when "11", --rt and rs hazard check
        '0' when others;

    --checks for control hazards
    s_control_Hazard <= s_check(2) or s_branch_final; --s_check(2) for jumps, s_branch_final if branching then flush once

    s_data_hazard_and_lw <= (s_data_hazard and not s_check(3)) or i_LW_STALL or i_EX_halt or i_DMEM_halt;

    --outputs according flushes and stalls according to the hazards
    o_IF_ID_STALL <= s_data_hazard_and_lw;
    o_ID_EX_STALL <= '0';
    o_EX_DMEM_STALL <= '0';
    o_DMEM_WB_STALL <= '0';
    o_IF_ID_FLUSH <= not s_data_hazard_and_lw and s_control_Hazard;
    o_ID_EX_FLUSH <= s_data_hazard_and_lw;
    o_EX_DMEM_FLUSH <= '0';
    o_DMEM_WB_FLUSH <= '0';
    o_PC_STALL <= s_data_hazard_and_lw;

end dataflow;