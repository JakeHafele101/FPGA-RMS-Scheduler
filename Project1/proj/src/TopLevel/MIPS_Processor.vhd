-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic (N : integer := DATA_WIDTH);
  port (
    iCLK      : in std_logic;
    iRST      : in std_logic;
    iInstLd   : in std_logic;
    iInstAddr : in std_logic_vector(N - 1 downto 0);
    iInstExt  : in std_logic_vector(N - 1 downto 0);
    oALUOut   : out std_logic_vector(N - 1 downto 0)); -- Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end MIPS_Processor;
architecture mixed of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr : std_logic; -- use this signal as the final active high data memory write enable signal
  signal s_DMemAddr : std_logic_vector(N - 1 downto 0); -- use this signal as the final data memory address input
  signal s_DMemData : std_logic_vector(N - 1 downto 0); -- use this signal as the final data memory data input
  signal s_DMemOut : std_logic_vector(N - 1 downto 0); -- use this signal as the data memory output

  -- Required register file signals 
  signal s_RegWr : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData : std_logic_vector(N - 1 downto 0); -- use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr : std_logic_vector(N - 1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N - 1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Inst : std_logic_vector(N - 1 downto 0); -- use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt : std_logic; -- this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl : std_logic; -- this signal indicates an overflow exception would have been initiated

  -- Generated, DO NOT TOUCH THE GLASS
  component mem is
    generic (
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer);
    port (
      clk  : in std_logic;
      addr : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
      data : in std_logic_vector((DATA_WIDTH - 1) downto 0);
      we   : in std_logic := '1';
      q    : out std_logic_vector((DATA_WIDTH - 1) downto 0));
  end component;

  component fetch is
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
  end component;

  component control is
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
      o_out_SEL           : out std_logic_vector(1 downto 0)  -- ALU Control, MUX select for source submodule output
    );
  end component;

  component reg_file is
    port (
      i_CLK     : in std_logic;                       -- Clock input
      i_RST     : in std_logic;                       -- Reset input
      i_rs_ADDR : in std_logic_vector(4 downto 0);    -- RS first operand reg num
      i_rt_ADDR : in std_logic_vector(4 downto 0);    -- RT second operand reg num
      i_rd_ADDR : in std_logic_vector(4 downto 0);    -- Write enable input
      i_rd_WE   : in std_logic;                       -- Write enable for destination reg RD
      i_rd_DATA : in std_logic_vector(31 downto 0);   -- RD destination reg to write to
      o_rs_DATA : out std_logic_vector(31 downto 0);  -- RS reg data output
      o_rt_DATA : out std_logic_vector(31 downto 0)); -- RT reg data output
  end component;

  component ALU is
    port (
      i_nAdd_Sub   : in std_logic;
      i_shift_Sel  : in std_logic_vector(1 downto 0);
      i_branch_Sel : in std_logic_vector(2 downto 0);
      i_logic_Sel  : in std_logic_vector(1 downto 0);
      i_out_Sel    : in std_logic_vector(1 downto 0);
      i_rs         : in std_logic_vector(31 downto 0);
      i_rt         : in std_logic_vector(31 downto 0);
      i_shamt      : in std_logic_vector(4 downto 0);
      o_branch     : out std_logic;
      o_overflow   : out std_logic;
      o_rd         : out std_logic_vector(31 downto 0));
  end component;

  component extend_16t32 is
    port (
      i_A          : in std_logic_vector(15 downto 0); --16 bit input
      i_nZero_Sign : in std_logic := '1';              --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
      o_F          : out std_logic_vector(31 downto 0) --32 bit output
    );

  end component;

  -- You may add any additional signals or components your implementation requires below this comment

  -- fetch
  signal s_branch : std_logic; --from ALU
  signal s_PC_4 : std_logic_vector(31 downto 0);

  --instruction memory decode
  signal s_OPCODE, s_FUNCT : std_logic_vector(5 downto 0);
  signal s_rt_ADDR, s_rs_ADDR, s_rd_ADDR : std_logic_vector(4 downto 0);
  signal s_SHAMT : std_logic_vector(4 downto 0);
  signal s_IMM : std_logic_vector(15 downto 0);
  signal s_J_ADDR : std_logic_vector(25 downto 0);

  -- from control
  signal s_nZero_Sign : std_logic;
  signal s_ALUSrc : std_logic;
  signal s_overflow_chk : std_logic;
  signal s_branch_chk : std_logic;
  signal s_reg_DST_ADDR_SEL : std_logic_vector (1 downto 0); --select line for i_rd_ADDR MUX
  signal s_reg_DST_DATA_SEL : std_logic_vector (1 downto 0);--select line for i_rd_DATA MUX
  signal s_PC_SEL : std_logic_vector(1 downto 0);

  -- from control to ALU
  signal s_nAdd_Sub : std_logic; -- ALU Control, 0 if add, 1 if sub
  signal s_shift_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for shift output
  signal s_branch_SEL : std_logic_vector(2 downto 0); -- ALU Control, MUX select for branch indicator output
  signal s_logic_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for logic output
  signal s_out_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for source submodule output

  --ALU
  signal s_rs_DATA : std_logic_vector(31 downto 0); --also used for fetch
  signal s_rt_DATA : std_logic_vector(31 downto 0);
  signal s_ALUOut : std_logic_vector(31 downto 0);
  --i_rd_DATA MUX
  signal s_rt_DATA_MUX : std_logic_vector (31 downto 0);

  --sign extender
  signal s_IMM_EXT : std_logic_vector (31 downto 0);

  --Overflow AND
  signal s_overflow : std_logic;


  --branch and link logic
  signal s_branchAndLink : std_logic;
  signal s_RegWrMux : std_logic;

begin

  -- This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
    iInstAddr when others;

  IMem : mem
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  port map(
    clk  => iCLK,
    addr => s_IMemAddr(11 downto 2),
    data => iInstExt,
    we   => iInstLd,
    q    => s_Inst);

  DMem : mem
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  port map(
    clk  => iCLK,
    addr => s_DMemAddr(11 downto 2),
    data => s_DMemData,
    we   => s_DMemWr,
    q    => s_DMemOut);

  -- Implement the rest of your processor below this comment! 

  -- Instruction decode to internal signals
  s_OPCODE <= s_Inst(31 downto 26);
  s_FUNCT <= s_Inst(5 downto 0);
  s_rt_ADDR <= s_Inst(20 downto 16);
  s_rs_ADDR <= s_Inst(25 downto 21);
  s_rd_ADDR <= s_Inst(15 downto 11);
  s_SHAMT <= s_Inst(10 downto 6);
  s_IMM <= s_Inst(15 downto 0);
  s_J_ADDR <= s_Inst(25 downto 0);

  g_fetch : fetch
  port map(
    i_CLK        => iCLK,
    i_PC_RST     => iRST,
    i_PC_SEL     => s_PC_SEL,
    i_branch     => s_branch,
    i_branch_chk => s_branch_chk,
    i_IMM_EXT    => s_IMM_EXT,
    i_RS_DATA    => s_rs_DATA,
    i_J_ADDR     => s_J_ADDR,
    o_PC         => s_NextInstAddr,
    o_PC_4       => s_PC_4
  );

  g_control : control
  port map(
    i_OPCODE            => s_OPCODE,           --Opcode, instruction[31:26]
    i_FUNCT             => s_FUNCT,            --Function of R-type instruction
    i_RT_ADDR           => s_rt_ADDR,          --RT address of instruction
    o_halt              => s_Halt,             --If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
    o_extend_nZero_Sign => s_nZero_Sign,       -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
    o_ALUSrc            => s_ALUSrc,           -- If 0, use register source. If 1, use immediate
    o_overflow_chk      => s_overflow_chk,     -- If 1, enable check for overflow
    o_branch_chk        => s_branch_chk,       -- If 1, enable check for branch
    o_reg_DST_ADDR_SEL  => s_reg_DST_ADDR_SEL, --MUX select for source of destination register address
    o_reg_DST_DATA_SEL  => s_reg_DST_DATA_SEL, --MUX select for source of destination register data
    o_PC_SEL            => s_PC_SEL,           -- Fetch Control, MUX select for source of PC increment
    o_reg_WE            => s_RegWrMux,            -- if 1, write to destiantion register 
    o_mem_WE            => s_DMemWr,           -- if 1, write to memory
    o_nAdd_Sub          => s_nAdd_Sub,         -- ALU Control, 0 if add, 1 if sub
    o_shift_SEL         => s_shift_SEL,        -- ALU Control, MUX select for shift output
    o_branch_SEL        => s_branch_SEL,       -- ALU Control, MUX select for branch indicator output
    o_logic_SEL         => s_logic_SEL,        -- ALU Control, MUX select for logic output
    o_out_SEL           => s_out_SEL           -- ALU Control, MUX select for source submodule output
  );

  g_reg_File : reg_file
  port map(
    i_CLK     => iCLK,
    i_RST     => iRST,
    i_rs_ADDR => s_rs_ADDR,
    i_rt_ADDR => s_rt_ADDR,
    i_rd_ADDR => s_RegWrAddr,
    i_rd_WE   => s_RegWr,
    i_rd_DATA => s_RegWrData,
    o_rs_DATA => s_rs_DATA,
    o_rt_DATA => s_rt_DATA);

  g_extend : extend_16t32
  port map(
    i_A          => s_IMM,
    i_nZero_Sign => s_nZero_Sign,
    o_F          => s_IMM_EXT);

  g_ALU : ALU
  port map(
    i_nAdd_Sub   => s_nAdd_Sub,
    i_shift_Sel  => s_shift_SEL,
    i_branch_Sel => s_branch_SEL,
    i_logic_Sel  => s_logic_SEL,
    i_out_Sel    => s_out_SEL,
    i_rs         => s_rs_DATA,
    i_rt         => s_rt_DATA_MUX,
    i_shamt      => s_SHAMT,
    o_branch     => s_branch,
    o_overflow   => s_overflow,
    o_rd         => s_ALUOut
  );
  
  -- Mux for register file rd address
  with s_reg_DST_ADDR_SEL select
  s_RegWrAddr <= s_rd_ADDR when "00",
                 s_rt_ADDR when "01",
                 "11111" when others; 

  -- Mux for register file rd address
  with s_reg_DST_DATA_SEL select
  s_RegWrData <= s_ALUOut when "00",
                 s_DMemOut when "01",
                 s_PC_4 when others; --R[31], $ra register for jal

  -- Mux for second ALU operand
  with s_ALUSrc select
    s_rt_DATA_MUX <= s_rt_DATA when '0',
                     s_IMM_EXT when others;

  -- AND gate to output overflow indication for add and sub
  s_Ovfl <= s_overflow_chk and s_overflow;

  --Dmem signal assignment
  s_DMemAddr <= s_ALUOut;
  s_DMemData <= s_rt_DATA;

  -- Assign ALU Output
  oALUOut <= s_ALUOut;

  -- Branch and Link regitster write control
  s_branchAndLink <= '1' WHEN s_branch_SEL  = "110" OR s_branch_SEL  = "011" ELSE '0';
  with s_branchAndLink select
    s_RegWr <= s_RegWrMux when '0',
               s_branch when others;

end mixed;