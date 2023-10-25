-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_second_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level register file second_datapath.vhd
--
--
-- NOTES:
-- Created 2/6/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_second_datapath is
    generic (gCLK_HPER : time := 10 ns);
end tb_second_datapath;

architecture mixed of tb_second_datapath is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component second_datapath is
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
    end component;

    -- Input signals of tested module
    signal i_CLK, i_RST, i_RD_WE : std_logic := '0';
    signal i_RS, i_RT, i_RD : std_logic_vector(4 downto 0) := "00000";

    signal i_IMM : std_logic_vector(15 downto 0) := X"0000";
    signal i_nAdd_Sub, i_ALU_SRC, i_SW, i_nADDER_MEM : std_logic := '0';

    -- Test signals
    signal s_INSTR_NAME : std_logic_vector(31 downto 0) := X"4E4F4E45"; --ASCII values for instruction names to read on modelsim :)
begin

    DUT0 : second_datapath
    port map(
        i_CLK        => i_CLK,
        i_RST        => i_RST,
        i_RS         => i_RS,
        i_RT         => i_RT,
        i_RD         => i_RD,
        i_RD_WE      => i_RD_WE,
        i_IMM        => i_IMM,
        i_nAdd_Sub   => i_nAdd_Sub,
        i_ALU_SRC    => i_ALU_SRC,
        i_nADDER_MEM => i_nADDER_MEM,
        i_SW         => i_SW);

    -- Clock period
    P_CLK : process
    begin
        i_CLK <= '0';
        wait for gCLK_HPER;
        i_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    -- Testbench process  
    P_DUT0 : process
    begin

        -- addi $25, $0, 0  #load &A into $25
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "11001"; -- reg operand 2
        i_RD <= "11001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444449"; -- 'ADDI'
        wait for cCLK_PER;

        -- addi $26, $0, 256  #load &B into $26
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "11010"; -- reg operand 2
        i_RD <= "11010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0100"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444449"; -- 'ADDI'
        wait for cCLK_PER;

        -- lw $1, 0($25)  #load A[0] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- lw $2, 4($25)  #load A[1] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0001"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- sw $1, 0($26)  # store $1 into B[0]
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        -- lw $2, 8($25)  #load A[2] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0002"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- sw $1, 4($26)  # store $1 into B[1]
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"0001"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        -- lw $2, 12($25)  #load A[3] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0003"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- sw $1, 8($26)  # store $1 into B[2]
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"0002"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        -- lw $2, 16($25)  #load A[4] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0004"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- sw $1, 12($26)  # store $1 into B[3]
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"0003"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        -- lw $2, 20($25)  #load A[5] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0005"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- sw $1, 16($26)  # store $1 into B[4]
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"0004"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        -- lw $2, 24($25)  #load A[6] into $2
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0006"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- add $1, $1, $2  # $1 = $1 + $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is RT
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444420"; -- 'ADD '
        wait for cCLK_PER;

        -- addi $27, $0, 512  #load &B into $27
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "11011"; -- reg operand 2
        i_RD <= "11011"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0200"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"41444449"; -- 'ADDI'
        wait for cCLK_PER;

        -- sw $1, -4($27)  # store $1 into B[255]
        i_RST <= '0';
        i_RS <= "11011"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00000"; -- destination reg
        i_RD_WE <= '0'; -- write to reg
        i_IMM <= X"FFFF"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '0'; -- loaded data from adder
        i_SW <= '1'; -- store
        s_INSTR_NAME <= X"20535720"; -- ' SW '
        wait for cCLK_PER;

        --Increment through array A to verify nothing changed
        -- #load A[0] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[1] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0001"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[2] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0002"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[3] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0003"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[4] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0004"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[5] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0005"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load A[6] into $1
        i_RST <= '0';
        i_RS <= "11001"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0006"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- Increment through array B to verify final array is {3, 6, 10, 15, 21, ... 31, 256}
        -- #load B[0] into $1
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[1] into $1
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0001"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[2] into $1
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0002"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[3] into $1
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0003"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[4] into $1
        i_RST <= '0';
        i_RS <= "11010"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0004"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[255] into $1
        i_RST <= '0';
        i_RS <= "11011"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"FFFF"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        -- #load B[256] into $1
        i_RST <= '0';
        i_RS <= "11011"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        i_nADDER_MEM <= '1'; -- loaded data from mem
        i_SW <= '0'; -- No store
        s_INSTR_NAME <= X"204C5720"; -- ' LW '
        wait for cCLK_PER;

        wait;
    end process;

end mixed;