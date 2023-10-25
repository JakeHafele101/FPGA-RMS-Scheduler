-------------------------------------------------------------------------
-- Jake Hafele
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_first_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- top level register file first_datapath.vhd
--
--
-- NOTES:
-- Created 2/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_first_datapath is
    generic (gCLK_HPER : time := 10 ns);
end tb_first_datapath;

architecture mixed of tb_first_datapath is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;

    component first_datapath is
        port (
            i_CLK      : in std_logic;                      -- Clock input
            i_RST      : in std_logic;                      -- Reset input
            i_RS       : in std_logic_vector(4 downto 0);   -- RS first operand reg num
            i_RT       : in std_logic_vector(4 downto 0);   -- RT second operand reg num
            i_RD       : in std_logic_vector(4 downto 0);   -- Write enable input
            i_RD_WE    : in std_logic;                      -- Write enable input
            i_IMM      : in std_logic_vector (31 downto 0); -- 32 bit immediate value for add/sub
            i_nAdd_Sub : in std_logic;                      -- if 0, add. if 1, subtract
            i_ALU_SRC  : in std_logic);                     -- if 0, second operand is register RT. If 1, second op is immediate
    end component;

    -- Input signals of tested module
    signal i_CLK, i_RST, i_RD_WE : std_logic := '0';
    signal i_RS, i_RT, i_RD : std_logic_vector(4 downto 0) := "00000";

    signal i_IMM : std_logic_vector(31 downto 0) := X"00000000";
    signal i_nAdd_Sub, i_ALU_SRC : std_logic := '0';

    -- Test signals
    signal s_RD_DATA_Expected : std_logic_vector (31 downto 0) := X"00000000";

begin

    DUT0 : first_datapath
    port map(
        i_CLK      => i_CLK,
        i_RST      => i_RST,
        i_RS       => i_RS,
        i_RT       => i_RT,
        i_RD       => i_RD,
        i_RD_WE    => i_RD_WE,
        i_IMM      => i_IMM,
        i_nAdd_Sub => i_nAdd_Sub,
        i_ALU_SRC  => i_ALU_SRC);

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

        -- Reset reg file
        i_RST <= '1';
        i_RS <= "00000";
        i_RT <= "00000";
        i_RD <= "00000";
        i_RD_WE <= '0';
        i_IMM <= X"00000000";
        i_nAdd_Sub <= '0';
        i_ALU_SRC <= '0';
        s_RD_DATA_Expected <= X"00000000";
        wait for cCLK_PER;

        -- addi $1, $0, 1
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00001"; -- reg operand 2
        i_RD <= "00001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000001"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000001";
        wait for cCLK_PER;

        -- addi $2, $0, 2
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "00010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000002"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000002";
        wait for cCLK_PER;

        -- addi $3, $0, 3
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00011"; -- reg operand 2
        i_RD <= "00011"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000003"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000003";
        wait for cCLK_PER;

        -- addi $4, $0, 4
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00100"; -- reg operand 2
        i_RD <= "00100"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000004"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000004";
        wait for cCLK_PER;

        -- addi $5, $0, 5
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00101"; -- reg operand 2
        i_RD <= "00101"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000005"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000005";
        wait for cCLK_PER;

        -- addi $6, $0, 6
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00110"; -- reg operand 2
        i_RD <= "00110"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000006"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000006";
        wait for cCLK_PER;

        -- addi $7, $0, 7
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00111"; -- reg operand 2
        i_RD <= "00111"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000007"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000007";
        wait for cCLK_PER;

        -- addi $8, $0, 8
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "01000"; -- reg operand 2
        i_RD <= "01000"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000008"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000008";
        wait for cCLK_PER;

        -- addi $9, $0, 9
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "01001"; -- reg operand 2
        i_RD <= "01001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000009"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"00000009";
        wait for cCLK_PER;

        -- addi $10, $0, 10
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "01010"; -- reg operand 2
        i_RD <= "01010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"0000000A"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"0000000A";
        wait for cCLK_PER;
    
        -- add $11, $1, $2
        i_RST <= '0';
        i_RS <= "00001"; -- reg operand 1
        i_RT <= "00010"; -- reg operand 2
        i_RD <= "01011"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000003"; -- (3)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "01011"; --Verify reg written
        wait for cCLK_PER;

        -- sub $12, $11, $3
        i_RST <= '0';
        i_RS <= "01011"; -- reg operand 1
        i_RT <= "00011"; -- reg operand 2
        i_RD <= "01100"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '1'; -- sub 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000000"; -- (0)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "01100"; --Verify reg written
        wait for cCLK_PER;
        
        -- add $13, $12, $4
        i_RST <= '0';
        i_RS <= "01100"; -- reg operand 1
        i_RT <= "00100"; -- reg operand 2
        i_RD <= "01101"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000004"; -- (4)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "01101"; --Verify reg written
        wait for cCLK_PER;

        -- sub $14, $13, $5
        i_RST <= '0';
        i_RS <= "01101"; -- reg operand 1
        i_RT <= "00101"; -- reg operand 2
        i_RD <= "01110"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '1'; -- sub 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"FFFFFFFF"; -- (-1)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "01110"; --Verify reg written
        wait for cCLK_PER;

        -- add $15, $14, $6
        i_RST <= '0';
        i_RS <= "01110"; -- reg operand 1
        i_RT <= "00110"; -- reg operand 2
        i_RD <= "01111"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000005"; -- (5)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "01111"; --Verify reg written
        wait for cCLK_PER;

        -- sub $16, $15, $7
        i_RST <= '0';
        i_RS <= "01111"; -- reg operand 1
        i_RT <= "00111"; -- reg operand 2
        i_RD <= "10000"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '1'; -- sub 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"FFFFFFFE"; -- (-2)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10000"; --Verify reg written
        wait for cCLK_PER;

        -- add $17, $16, $8
        i_RST <= '0';
        i_RS <= "10000"; -- reg operand 1
        i_RT <= "01000"; -- reg operand 2
        i_RD <= "10001"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000006"; -- (6)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10001"; --Verify reg written
        wait for cCLK_PER;

        -- sub $18, $17, $9
        i_RST <= '0';
        i_RS <= "10001"; -- reg operand 1
        i_RT <= "01001"; -- reg operand 2
        i_RD <= "10010"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '1'; -- sub 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"FFFFFFFD"; -- (-3)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10010"; --Verify reg written
        wait for cCLK_PER;

        -- add $19, $18, $10
        i_RST <= '0';
        i_RS <= "10010"; -- reg operand 1
        i_RT <= "01010"; -- reg operand 2
        i_RD <= "10011"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"00000007"; -- (7)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10011"; --Verify reg written
        wait for cCLK_PER;

        -- addi $20, $0, -35
        i_RST <= '0';
        i_RS <= "00000"; -- reg operand 1
        i_RT <= "00000"; -- reg operand 2
        i_RD <= "10100"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"FFFFFFDD"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '1'; -- second op is immediate
        s_RD_DATA_Expected <= X"FFFFFFDD"; -- (-35)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10100"; --Verify reg written
        wait for cCLK_PER;

        -- add $21, $19, $20
        i_RST <= '0';
        i_RS <= "10011"; -- reg operand 1
        i_RT <= "10100"; -- reg operand 2
        i_RD <= "10101"; -- destination reg
        i_RD_WE <= '1'; -- write to reg
        i_IMM <= X"00000000"; -- immediate operand 2
        i_nAdd_Sub <= '0'; -- add 
        i_ALU_SRC <= '0'; -- second op is register
        s_RD_DATA_Expected <= X"FFFFFFE4"; -- (-28)
        wait for cCLK_PER;
        i_RD_WE <= '0'; -- don't write while verifying reg
        i_RT <= "10101"; --Verify reg written
        wait for cCLK_PER;

        wait;
    end process;

end mixed;