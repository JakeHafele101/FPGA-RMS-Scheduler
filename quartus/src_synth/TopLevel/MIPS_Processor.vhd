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
    iCLK             : in std_logic;
    iRST             : in std_logic;
    iInstLd          : in std_logic;
    iInstAddr        : in std_logic_vector(N - 1 downto 0);
    iInstExt         : in std_logic_vector(N - 1 downto 0);
    o_IF_Imem        : out std_logic_vector(N - 1 downto 0);
    o_EX_ALUOut      : out std_logic_vector(N - 1 downto 0);
    o_EX_RegWrAddr   : out std_logic_vector(4 downto 0);
    o_WB_RegWrData   : out std_logic_vector (N - 1 downto 0);
    o_DMEM_DMEM_DATA : out std_logic_vector(N - 1 downto 0);
    o_EX_RegWr       : out std_logic;
    o_DMEM_mem_WE    : out std_logic;
    o_halt    : out std_logic;
    o_overflow    : out std_logic
  ); -- Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

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
  component imem is
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

  component dmem is
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

  component prefetch is
    port (
      i_CLK        : in std_logic;                      --Clock for PC DFF
      i_PC_RST     : in std_logic;                      -- reset for PC counter DFF
      i_PC_SEL     : in std_logic_vector(1 downto 0);   -- 2 bit select line from Control Module. Dictates what output will be MUXed to PC
      i_branch     : in std_logic;                      -- indicator to branch from ALU based on operand comparison
      i_branch_chk : in std_logic;                      -- indicator to branch from Control Module based on instruction read
      i_IMM_EXT    : in std_logic_vector(31 downto 0);  -- 32 bit extended immediate, used for branch instructions
      i_RS_DATA    : in std_logic_vector(31 downto 0);  -- Contents of second source register, used for jr, PC = R[Rs]
      i_J_ADDR     : in std_logic_vector(25 downto 0);  -- adress field of J-type instruction, used for jump instructions to update PC
      i_PC_STALL   : in std_logic;                      --If stall is 1, don't write to PC
      o_PC         : out std_logic_vector(31 downto 0); -- Program Counter, address used to access instruction memory on top level
      o_PC_4       : out std_logic_vector(31 downto 0)  -- Program Counter + 4, wired to destination register write data for jal instruction, so $ra updates
    );
  end component;

  component control is
    port (
      i_OPCODE            : in std_logic_vector(5 downto 0);  -- Opcode, instruction[31:26]
      i_FUNCT             : in std_logic_vector(5 downto 0);  -- Function of R-type instruction
      i_RT_ADDR           : in std_logic_vector(4 downto 0);  -- RT address of instruction
      o_reg_WE_SEL        : out std_logic;                    -- AND with branch conditional to control reg_Wr to write to R[31] for branch and link. If 1, branch zero link instruction
      o_halt              : out std_logic;                    -- If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
      o_extend_nZero_Sign : out std_logic;                    -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
      o_ALUSrc            : out std_logic;                    -- If 0, use register source. If 1, use immediate
      o_overflow_chk      : out std_logic;                    -- If 1, enable check for overflow
      o_branch_chk        : out std_logic;                    -- If 1, enable check for branch
      o_reg_DST_ADDR_SEL  : out std_logic_vector(1 downto 0); -- MUX select for source of destination register address
      o_reg_DST_DATA_SEL  : out std_logic_vector(1 downto 0); -- MUX select for source of destination register data
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

  component hazardDetection is
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

  component branch is
    port (
      i_branch_Sel : in std_logic_vector(2 downto 0); -- Selects which branch instruction evaluated
      i_rs         : in std_logic_vector(31 downto 0);
      i_rt         : in std_logic_vector(31 downto 0);
      o_branch     : out std_logic); -- If 1, update PC with branch address. If 0, use PC + 4 for branch instructions
  end component;

  component ALU is
    port (
      i_nAdd_Sub  : in std_logic;
      i_shift_Sel : in std_logic_vector(1 downto 0);
      i_logic_Sel : in std_logic_vector(1 downto 0);
      i_out_Sel   : in std_logic_vector(1 downto 0);
      i_rs        : in std_logic_vector(31 downto 0);
      i_rt        : in std_logic_vector(31 downto 0);
      i_shamt     : in std_logic_vector(4 downto 0);
      o_overflow  : out std_logic;
      o_rd        : out std_logic_vector(31 downto 0));
  end component;

  component extend_16t32 is
    port (
      i_A          : in std_logic_vector(15 downto 0); --16 bit input
      i_nZero_Sign : in std_logic := '1';              --control bit to extend 0 or sign. if 0, extend 0's. if 1, extend MSB of i_A
      o_F          : out std_logic_vector(31 downto 0) --32 bit output
    );
  end component;

  component IF_ID_BufferReg is
    port (
      i_CLK   : in std_logic; -- Clock input
      i_RST   : in std_logic; -- Reset input
      i_stall : in std_logic; -- Write Enable to all registers
      i_flush : in std_logic; -- If 1, write 0 to all regs

      i_IF_PC_4  : in std_logic_vector(31 downto 0);
      i_IF_Instr : in std_logic_vector(31 downto 0);

      o_ID_PC_4  : out std_logic_vector(31 downto 0);
      o_ID_Instr : out std_logic_vector(31 downto 0));
  end component;

  component ID_EX_BufferReg is
    port (
      i_CLK   : in std_logic; -- Clock input
      i_RST   : in std_logic; -- Reset input
      i_stall : in std_logic; -- Write Enable to all registers
      i_flush : in std_logic; -- If 1, write 0 to all regs

      i_ID_OPCODE           : in std_logic_vector(5 downto 0);
      i_ID_FUNCT            : in std_logic_vector(5 downto 0);
      i_ID_reg_WE_SEL       : in std_logic_vector(0 downto 0);
      i_ID_Halt             : in std_logic_vector(0 downto 0);
      i_ID_ALUSrc           : in std_logic_vector(0 downto 0);
      i_ID_overflow_chk     : in std_logic_vector(0 downto 0);
      i_ID_reg_DST_ADDR_SEL : in std_logic_vector(1 downto 0);
      i_ID_reg_DST_DATA_SEL : in std_logic_vector(1 downto 0);
      i_ID_reg_WE           : in std_logic_vector(0 downto 0);
      i_ID_mem_WE           : in std_logic_vector(0 downto 0);
      i_ID_nAdd_Sub         : in std_logic_vector(0 downto 0);
      i_ID_shift_SEL        : in std_logic_vector(1 downto 0);
      i_ID_logic_SEL        : in std_logic_vector(1 downto 0);
      i_ID_out_SEL          : in std_logic_vector(1 downto 0);
      i_ID_branch           : in std_logic_vector(0 downto 0);
      i_ID_PC_4             : in std_logic_vector(31 downto 0);
      i_ID_rs_ADDR          : in std_logic_vector(4 downto 0);
      i_ID_rt_ADDR          : in std_logic_vector(4 downto 0);
      i_ID_rd_ADDR          : in std_logic_vector(4 downto 0);
      i_ID_SHAMT            : in std_logic_vector(4 downto 0);
      i_ID_rs_DATA          : in std_logic_vector(31 downto 0);
      i_ID_rt_DATA          : in std_logic_vector(31 downto 0);
      i_ID_IMM_EXT          : in std_logic_vector(31 downto 0);

      o_EX_OPCODE           : out std_logic_vector(5 downto 0);
      o_EX_FUNCT            : out std_logic_vector(5 downto 0);
      o_EX_reg_WE_SEL       : out std_logic_vector(0 downto 0);
      o_EX_Halt             : out std_logic_vector(0 downto 0);
      o_EX_ALUSrc           : out std_logic_vector(0 downto 0);
      o_EX_overflow_chk     : out std_logic_vector(0 downto 0);
      o_EX_reg_DST_ADDR_SEL : out std_logic_vector(1 downto 0);
      o_EX_reg_DST_DATA_SEL : out std_logic_vector(1 downto 0);
      o_EX_reg_WE           : out std_logic_vector(0 downto 0);
      o_EX_mem_WE           : out std_logic_vector(0 downto 0);
      o_EX_nAdd_Sub         : out std_logic_vector(0 downto 0);
      o_EX_shift_SEL        : out std_logic_vector(1 downto 0);
      o_EX_logic_SEL        : out std_logic_vector(1 downto 0);
      o_EX_out_SEL          : out std_logic_vector(1 downto 0);
      o_EX_branch           : out std_logic_vector(0 downto 0);
      o_EX_PC_4             : out std_logic_vector(31 downto 0);
      o_EX_rs_ADDR          : out std_logic_vector(4 downto 0);
      o_EX_rt_ADDR          : out std_logic_vector(4 downto 0);
      o_EX_rd_ADDR          : out std_logic_vector(4 downto 0);
      o_EX_SHAMT            : out std_logic_vector(4 downto 0);
      o_EX_rs_DATA          : out std_logic_vector(31 downto 0);
      o_EX_rt_DATA          : out std_logic_vector(31 downto 0);
      o_EX_IMM_EXT          : out std_logic_vector(31 downto 0));
  end component;

  component EX_DMEM_BufferReg is
    port (
      i_CLK   : in std_logic; -- Clock input
      i_RST   : in std_logic; -- Reset input
      i_stall : in std_logic; -- Write Enable to all registers
      i_flush : in std_logic; -- If 1, write 0 to all regs

      i_EX_Halt              : in std_logic_vector(0 downto 0);
      i_EX_overflow_chk      : in std_logic_vector(0 downto 0);
      i_EX_reg_DST_DATA_SEL  : in std_logic_vector(1 downto 0);
      i_EX_mem_WE            : in std_logic_vector(0 downto 0);
      i_EX_PC_4              : in std_logic_vector(31 downto 0);
      i_EX_DMEM_DATA_MUX_FWD : in std_logic_vector(31 downto 0);
      i_EX_ALUOut            : in std_logic_vector(31 downto 0);
      i_EX_overflow          : in std_logic_vector(0 downto 0);
      i_EX_RegWr             : in std_logic_vector(0 downto 0);
      i_EX_RegWrAddr         : in std_logic_vector(4 downto 0);

      o_DMEM_Halt              : out std_logic_vector(0 downto 0);
      o_DMEM_overflow_chk      : out std_logic_vector(0 downto 0);
      o_DMEM_reg_DST_DATA_SEL  : out std_logic_vector(1 downto 0);
      o_DMEM_mem_WE            : out std_logic_vector(0 downto 0);
      o_DMEM_PC_4              : out std_logic_vector(31 downto 0);
      o_DMEM_DMEM_DATA_MUX_FWD : out std_logic_vector(31 downto 0);
      o_DMEM_ALUOut            : out std_logic_vector(31 downto 0);
      o_DMEM_overflow          : out std_logic_vector(0 downto 0);
      o_DMEM_RegWr             : out std_logic_vector(0 downto 0);
      o_DMEM_RegWrAddr         : out std_logic_vector(4 downto 0)
    );
  end component;

  component DMEM_WB_BufferReg is
    port (
      i_CLK   : in std_logic; -- Clock input
      i_RST   : in std_logic; -- Reset input
      i_stall : in std_logic; -- Write Enable to all registers
      i_flush : in std_logic; -- If 1, write 0 to all regs

      i_DMEM_Halt             : in std_logic_vector(0 downto 0);
      i_DMEM_overflow_chk     : in std_logic_vector(0 downto 0);
      i_DMEM_reg_DST_DATA_SEL : in std_logic_vector(1 downto 0);
      i_DMEM_PC_4             : in std_logic_vector(31 downto 0);
      i_DMEM_ALUOut           : in std_logic_vector(31 downto 0);
      i_DMEM_overflow         : in std_logic_vector(0 downto 0);
      i_DMEM_DMEM_DATA        : in std_logic_vector(31 downto 0);
      i_DMEM_RegWr            : in std_logic_vector(0 downto 0);
      i_DMEM_RegWrAddr        : in std_logic_vector(4 downto 0);

      o_WB_Halt             : out std_logic_vector(0 downto 0);
      o_WB_overflow_chk     : out std_logic_vector(0 downto 0);
      o_WB_reg_DST_DATA_SEL : out std_logic_vector(1 downto 0);
      o_WB_PC_4             : out std_logic_vector(31 downto 0);
      o_WB_ALUOut           : out std_logic_vector(31 downto 0);
      o_WB_overflow         : out std_logic_vector(0 downto 0);
      o_WB_DMEM_DATA        : out std_logic_vector(31 downto 0);
      o_WB_RegWr            : out std_logic_vector(0 downto 0);
      o_WB_RegWrAddr        : out std_logic_vector(4 downto 0)
    );
  end component;

  component forward is
    port (
      i_EX_OPCODE          : in std_logic_vector(5 downto 0);  -- Opcode, instruction[31:26]
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
  end component;

  -- You may add any additional signals or components your implementation requires below this comment

  -- Cross Stage Signals
  signal s_IF_ID_STALL, s_ID_EX_STALL, s_EX_DMEM_STALL, s_DMEM_WB_STALL, s_PC_STALL : std_logic; --Stall control from hazard detection
  signal s_IF_ID_FLUSH, s_ID_EX_FLUSH, s_EX_DMEM_FLUSH, s_DMEM_WB_FLUSH : std_logic; --Flush control from hazard detection
  signal s_LW_STALL : std_logic;

  -- IF SIGNALS
  -- prefetch
  signal s_IF_PC : std_logic_vector(31 downto 0);
  signal s_IF_PC_4 : std_logic_vector(31 downto 0);

  -- ID SIGNALS
  -- from control
  signal s_ID_reg_WE_SEL : std_logic_vector(0 downto 0);
  signal s_ID_Halt : std_logic_vector(0 downto 0);
  signal s_ID_nZero_Sign : std_logic_vector(0 downto 0);
  signal s_ID_ALUSrc : std_logic_vector(0 downto 0);
  signal s_ID_overflow_chk : std_logic_vector(0 downto 0);
  signal s_ID_branch_chk : std_logic_vector(0 downto 0);
  signal s_ID_reg_DST_ADDR_SEL : std_logic_vector (1 downto 0); --select line for i_rd_ADDR MUX
  signal s_ID_reg_DST_DATA_SEL : std_logic_vector (1 downto 0);--select line for i_rd_DATA MUX
  signal s_ID_PC_SEL : std_logic_vector(1 downto 0);
  signal s_ID_reg_WE : std_logic_vector(0 downto 0);
  signal s_ID_mem_WE : std_logic_vector(0 downto 0);
  signal s_ID_branch_SEL : std_logic_vector(2 downto 0); -- ALU Control, MUX select for branch indicator output
  -- from control to ALU
  signal s_ID_nAdd_Sub : std_logic_vector(0 downto 0); -- ALU Control, 0 if add, 1 if sub
  signal s_ID_shift_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for shift output
  signal s_ID_logic_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for logic output
  signal s_ID_out_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for source submodule output
  -- prefetch
  signal s_ID_branch : std_logic_vector(0 downto 0); --from ALU
  signal s_ID_PC_4 : std_logic_vector(31 downto 0);
  signal s_ID_INSTR : std_logic_vector(31 downto 0);
  --instruction memory decode
  signal s_ID_OPCODE, s_ID_FUNCT : std_logic_vector(5 downto 0);
  signal s_ID_rt_ADDR, s_ID_rs_ADDR, s_ID_rd_ADDR : std_logic_vector(4 downto 0);
  signal s_ID_SHAMT : std_logic_vector(4 downto 0);
  signal s_ID_IMM : std_logic_vector(15 downto 0);
  signal s_ID_J_ADDR : std_logic_vector(25 downto 0);
  --Regfile
  signal s_ID_rs_DATA : std_logic_vector(31 downto 0); --also used for fetch
  signal s_ID_rt_DATA : std_logic_vector(31 downto 0);
  --sign extender
  signal s_ID_IMM_EXT : std_logic_vector (31 downto 0);

  -- EX SIGNALS
  signal s_EX_OPCODE : std_logic_vector(5 downto 0);
  signal s_EX_FUNCT : std_logic_vector(5 downto 0);
  -- from control
  signal s_EX_reg_WE_SEL : std_logic_vector(0 downto 0);
  signal s_EX_Halt : std_logic_vector(0 downto 0);
  signal s_EX_ALUSrc : std_logic_vector(0 downto 0);
  signal s_EX_overflow_chk : std_logic_vector(0 downto 0);
  signal s_EX_reg_DST_ADDR_SEL : std_logic_vector (1 downto 0); --select line for i_rd_ADDR MUX
  signal s_EX_reg_DST_DATA_SEL : std_logic_vector (1 downto 0);--select line for i_rd_DATA MUX
  signal s_EX_reg_WE : std_logic_vector(0 downto 0);
  signal s_EX_mem_WE : std_logic_vector(0 downto 0);
  -- from control to ALU
  signal s_EX_nAdd_Sub : std_logic_vector(0 downto 0); -- ALU Control, 0 if add, 1 if sub
  signal s_EX_shift_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for shift output
  signal s_EX_logic_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for logic output
  signal s_EX_out_SEL : std_logic_vector(1 downto 0); -- ALU Control, MUX select for source submodule output
  -- prefetch
  signal s_EX_branch : std_logic_vector(0 downto 0);
  signal s_EX_PC_4 : std_logic_vector(31 downto 0);
  --instruction memory decode
  signal s_EX_rs_ADDR : std_logic_vector(4 downto 0);
  signal s_EX_rt_ADDR : std_logic_vector(4 downto 0);
  signal s_EX_rd_ADDR : std_logic_vector(4 downto 0);
  signal s_EX_SHAMT : std_logic_vector(4 downto 0);
  --ALU
  signal s_EX_rs_DATA : std_logic_vector(31 downto 0); --also used for fetch
  signal s_EX_rt_DATA : std_logic_vector(31 downto 0);
  signal s_EX_ALUOut : std_logic_vector(31 downto 0);
  --i_rt_DATA MUX for ALU second operand
  signal s_EX_rt_DATA_MUX : std_logic_vector (31 downto 0);
  --sign extender
  signal s_EX_IMM_EXT : std_logic_vector (31 downto 0);
  --Overflow AND
  signal s_EX_overflow : std_logic_vector(0 downto 0);
  --Destination reg MUX
  signal s_EX_RegWr : std_logic_vector(0 downto 0);
  signal s_EX_RegWrAddr : std_logic_vector(4 downto 0);
  --Forwarding control MUX
  signal s_EX_RS_DATA_FWD_SEL : std_logic_vector(1 downto 0);
  signal s_EX_RT_DATA_FWD_SEL : std_logic_vector(1 downto 0);
  signal s_DMEM_DATA_FWD_SEL : std_logic_vector(1 downto 0);
  signal s_EX_RS_DATA_MUX_FWD : std_logic_vector(31 downto 0);
  signal s_EX_RT_DATA_MUX_FWD : std_logic_vector(31 downto 0);
  signal s_EX_DMEM_DATA_MUX_FWD : std_logic_vector(31 downto 0);

  -- DMEM SIGNALS
  -- from control
  signal s_DMEM_Halt : std_logic_vector(0 downto 0);
  signal s_DMEM_overflow_chk : std_logic_vector(0 downto 0);
  signal s_DMEM_reg_DST_DATA_SEL : std_logic_vector (1 downto 0);--select line for i_rd_DATA MUX
  signal s_DMEM_mem_WE : std_logic_vector(0 downto 0);
  -- prefetch
  signal s_DMEM_PC_4 : std_logic_vector(31 downto 0);
  --ALU
  signal s_DMEM_ALUOut : std_logic_vector(31 downto 0);
  --Overflow AND
  signal s_DMEM_overflow : std_logic_vector(0 downto 0);
  -- Data Memory
  signal s_DMEM_DMEM_DATA : std_logic_vector (31 downto 0);
  --Destination reg MUX
  signal s_DMEM_RegWr : std_logic_vector(0 downto 0);
  signal s_DMEM_RegWrAddr : std_logic_vector(4 downto 0);
  -- Forwarding control MUX propogate
  signal s_DMEM_DMEM_DATA_MUX_FWD : std_logic_vector(31 downto 0);

  -- WB SIGNALS
  -- from control
  signal s_WB_Halt : std_logic_vector(0 downto 0);
  signal s_WB_overflow_chk : std_logic_vector(0 downto 0);
  signal s_WB_reg_DST_DATA_SEL : std_logic_vector (1 downto 0);--select line for i_rd_DATA MUX
  -- prefetch
  signal s_WB_PC_4 : std_logic_vector(31 downto 0);
  --ALU
  signal s_WB_ALUOut : std_logic_vector(31 downto 0);
  --Overflow AND
  signal s_WB_overflow : std_logic_vector(0 downto 0);
  -- Data Memory
  signal s_WB_DMEM_DATA : std_logic_vector (31 downto 0);
  --Destination reg MUX
  signal s_WB_RegWr : std_logic_vector(0 downto 0);
  signal s_WB_RegWrAddr : std_logic_vector(4 downto 0);
begin

  -- This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
    iInstAddr when others;

  g_imem : imem
  generic map(
    ADDR_WIDTH => IMEM_ADDR_WIDTH, --CHANGED
    DATA_WIDTH => N)
  port map(
    clk  => iCLK,
    addr => s_IMemAddr(10 downto 0), --CHANGED
    data => iInstExt,
    we   => iInstLd,
    q    => s_Inst);

  g_dmem : dmem
  generic map(
    ADDR_WIDTH => DMEM_ADDR_WIDTH, --CHANGED
    DATA_WIDTH => N)
  port map(
    clk  => iCLK,
    addr => s_DMemAddr(9 downto 0), --CHANGED
    data => s_DMemData,
    we   => s_DMemWr,
    q    => s_DMemOut);

  -- Implement the rest of your processor below this comment! 

  -- Instruction decode to internal signals
  s_ID_OPCODE <= s_ID_INSTR(31 downto 26);
  s_ID_FUNCT <= s_ID_INSTR(5 downto 0);
  s_ID_rt_ADDR <= s_ID_INSTR(20 downto 16);
  s_ID_rs_ADDR <= s_ID_INSTR(25 downto 21);
  s_ID_rd_ADDR <= s_ID_INSTR(15 downto 11);
  s_ID_SHAMT <= s_ID_INSTR(10 downto 6);
  s_ID_IMM <= s_ID_INSTR(15 downto 0);
  s_ID_J_ADDR <= s_ID_INSTR(25 downto 0);

  g_IF_ID_BufferReg : IF_ID_BufferReg
  port map(
    i_CLK   => iCLK,
    i_RST   => iRST,
    i_stall => s_IF_ID_STALL,
    i_flush => s_IF_ID_FLUSH,

    i_IF_PC_4  => s_IF_PC_4,
    i_IF_Instr => s_Inst,

    o_ID_PC_4  => s_ID_PC_4,
    o_ID_Instr => s_ID_INSTR);

  g_ID_EX_BufferReg : ID_EX_BufferReg
  port map(
    i_CLK   => iCLK,
    i_RST   => iRST,
    i_stall => s_ID_EX_STALL,
    i_flush => s_ID_EX_FLUSH,

    i_ID_OPCODE           => s_ID_OPCODE,
    i_ID_FUNCT            => s_ID_FUNCT,
    i_ID_reg_WE_SEL       => s_ID_reg_WE_SEL,
    i_ID_Halt             => s_ID_Halt,
    i_ID_ALUSrc           => s_ID_ALUSrc,
    i_ID_overflow_chk     => s_ID_overflow_chk,
    i_ID_reg_DST_ADDR_SEL => s_ID_reg_DST_ADDR_SEL,
    i_ID_reg_DST_DATA_SEL => s_ID_reg_DST_DATA_SEL,
    i_ID_reg_WE           => s_ID_reg_WE,
    i_ID_mem_WE           => s_ID_mem_WE,
    i_ID_nAdd_Sub         => s_ID_nAdd_Sub,
    i_ID_shift_SEL        => s_ID_shift_SEL,
    i_ID_logic_SEL        => s_ID_logic_SEL,
    i_ID_out_SEL          => s_ID_out_SEL,
    i_ID_PC_4             => s_ID_PC_4,
    i_ID_branch           => s_ID_branch,
    i_ID_rs_ADDR          => s_ID_rs_ADDR,
    i_ID_rt_ADDR          => s_ID_rt_ADDR,
    i_ID_rd_ADDR          => s_ID_rd_ADDR,
    i_ID_SHAMT            => s_ID_SHAMT,
    i_ID_rs_DATA          => s_ID_rs_DATA,
    i_ID_rt_DATA          => s_ID_rt_DATA,
    i_ID_IMM_EXT          => s_ID_IMM_EXT,

    o_EX_OPCODE           => s_EX_OPCODE,
    o_EX_FUNCT            => s_EX_FUNCT,
    o_EX_reg_WE_SEL       => s_EX_reg_WE_SEL,
    o_EX_Halt             => s_EX_Halt,
    o_EX_ALUSrc           => s_EX_ALUSrc,
    o_EX_overflow_chk     => s_EX_overflow_chk,
    o_EX_reg_DST_ADDR_SEL => s_EX_reg_DST_ADDR_SEL,
    o_EX_reg_DST_DATA_SEL => s_EX_reg_DST_DATA_SEL,
    o_EX_reg_WE           => s_EX_reg_WE,
    o_EX_mem_WE           => s_EX_mem_WE,
    o_EX_nAdd_Sub         => s_EX_nAdd_Sub,
    o_EX_shift_SEL        => s_EX_shift_SEL,
    o_EX_logic_SEL        => s_EX_logic_SEL,
    o_EX_out_SEL          => s_EX_out_SEL,
    o_EX_branch           => s_EX_branch,
    o_EX_PC_4             => s_EX_PC_4,
    o_EX_rs_ADDR          => s_EX_rs_ADDR,
    o_EX_rt_ADDR          => s_EX_rt_ADDR,
    o_EX_rd_ADDR          => s_EX_rd_ADDR,
    o_EX_SHAMT            => s_EX_SHAMT,
    o_EX_rs_DATA          => s_EX_rs_DATA,
    o_EX_rt_DATA          => s_EX_rt_DATA,
    o_EX_IMM_EXT          => s_EX_IMM_EXT);

  g_EX_DMEM_BufferReg : EX_DMEM_BufferReg
  port map(
    i_CLK   => iCLK,
    i_RST   => iRST,
    i_stall => s_EX_DMEM_STALL,
    i_flush => s_EX_DMEM_FLUSH,

    i_EX_Halt              => s_EX_Halt,
    i_EX_overflow_chk      => s_EX_overflow_chk,
    i_EX_reg_DST_DATA_SEL  => s_EX_reg_DST_DATA_SEL,
    i_EX_mem_WE            => s_EX_mem_WE,
    i_EX_PC_4              => s_EX_PC_4,
    i_EX_DMEM_DATA_MUX_FWD => s_EX_DMEM_DATA_MUX_FWD,
    i_EX_ALUOut            => s_EX_ALUOut,
    i_EX_overflow          => s_EX_overflow,
    i_EX_RegWr             => s_EX_RegWr,
    i_EX_RegWrAddr         => s_EX_RegWrAddr,

    o_DMEM_Halt              => s_DMEM_Halt,
    o_DMEM_overflow_chk      => s_DMEM_overflow_chk,
    o_DMEM_reg_DST_DATA_SEL  => s_DMEM_reg_DST_DATA_SEL,
    o_DMEM_mem_WE            => s_DMEM_mem_WE,
    o_DMEM_PC_4              => s_DMEM_PC_4,
    o_DMEM_DMEM_DATA_MUX_FWD => s_DMEM_DMEM_DATA_MUX_FWD,
    o_DMEM_ALUOut            => s_DMEM_ALUOut,
    o_DMEM_overflow          => s_DMEM_overflow,
    o_DMEM_RegWr             => s_DMEM_RegWr,
    o_DMEM_RegWrAddr         => s_DMEM_RegWrAddr
  );

  g_DMEM_WB_BufferReg : DMEM_WB_BufferReg
  port map(
    i_CLK   => iCLK,
    i_RST   => iRST,
    i_stall => s_DMEM_WB_STALL,
    i_flush => s_DMEM_WB_FLUSH,

    i_DMEM_Halt             => s_DMEM_Halt,
    i_DMEM_overflow_chk     => s_DMEM_overflow_chk,
    i_DMEM_reg_DST_DATA_SEL => s_DMEM_reg_DST_DATA_SEL,
    i_DMEM_PC_4             => s_DMEM_PC_4,
    i_DMEM_ALUOut           => s_DMEM_ALUOut,
    i_DMEM_overflow         => s_DMEM_overflow,
    i_DMEM_DMEM_DATA        => s_DMEM_DMEM_DATA,
    i_DMEM_RegWr            => s_DMEM_RegWr,
    i_DMEM_RegWrAddr        => s_DMEM_RegWrAddr,

    o_WB_Halt             => s_WB_Halt,
    o_WB_overflow_chk     => s_WB_overflow_chk,
    o_WB_reg_DST_DATA_SEL => s_WB_reg_DST_DATA_SEL,
    o_WB_PC_4             => s_WB_PC_4,
    o_WB_ALUOut           => s_WB_ALUOut,
    o_WB_overflow         => s_WB_overflow,
    o_WB_DMEM_DATA        => s_WB_DMEM_DATA,
    o_WB_RegWr            => s_WB_RegWr,
    o_WB_RegWrAddr        => s_WB_RegWrAddr
  );

  g_prefetch : prefetch
  port map(
    i_CLK        => iCLK,
    i_PC_RST     => iRST,
    i_PC_SEL     => s_ID_PC_SEL,
    i_branch     => s_ID_branch(0),
    i_branch_chk => s_ID_branch_chk(0),
    i_IMM_EXT    => s_ID_IMM_EXT,
    i_RS_DATA    => s_ID_rs_DATA,
    i_J_ADDR     => s_ID_J_ADDR,
    i_PC_STALL   => s_PC_STALL,
    o_PC         => s_IF_PC, --nextInstrAddr
    o_PC_4       => s_IF_PC_4
  );

  g_control : control
  port map(
    i_OPCODE            => s_ID_OPCODE,           -- Opcode, instruction[31:26]
    i_FUNCT             => s_ID_FUNCT,            -- Function of R-type instruction
    i_RT_ADDR           => s_ID_rt_ADDR,          -- RT address of instruction
    o_reg_WE_SEL        => s_ID_reg_WE_SEL(0),    -- MUX for regWr between regWE and branch conditional
    o_halt              => s_ID_Halt(0),          -- If 0, not last instruction. if 1, last instruction. Driven by opcode 010100
    o_extend_nZero_Sign => s_ID_nZero_Sign(0),    -- If 0, sign extend 16 bit immediate with 0's. If 1, extend by Immediate[15] (the MSB)
    o_ALUSrc            => s_ID_ALUSrc(0),        -- If 0, use register source. If 1, use immediate
    o_overflow_chk      => s_ID_overflow_chk(0),  -- If 1, enable check for overflow
    o_branch_chk        => s_ID_branch_chk(0),    -- If 1, enable check for branch
    o_reg_DST_ADDR_SEL  => s_ID_reg_DST_ADDR_SEL, -- MUX select for source of destination register address
    o_reg_DST_DATA_SEL  => s_ID_reg_DST_DATA_SEL, -- MUX select for source of destination register data
    o_PC_SEL            => s_ID_PC_SEL,           -- Fetch Control, MUX select for source of PC increment
    o_reg_WE            => s_ID_reg_WE(0),        -- if 1, write to destiantion register 
    o_mem_WE            => s_ID_mem_WE(0),        -- if 1, write to memory
    o_nAdd_Sub          => s_ID_nAdd_Sub(0),      -- ALU Control, 0 if add, 1 if sub
    o_shift_SEL         => s_ID_shift_SEL,        -- ALU Control, MUX select for shift output
    o_branch_SEL        => s_ID_branch_SEL,       -- ALU Control, MUX select for branch indicator output
    o_logic_SEL         => s_ID_logic_SEL,        -- ALU Control, MUX select for logic output
    o_out_SEL           => s_ID_out_SEL           -- ALU Control, MUX select for source submodule output
  );

  g_reg_File : reg_file
  port map(
    i_CLK     => iCLK,
    i_RST     => iRST,
    i_rs_ADDR => s_ID_rs_ADDR,
    i_rt_ADDR => s_ID_rt_ADDR,
    i_rd_ADDR => s_RegWrAddr,
    i_rd_WE   => s_RegWr,
    i_rd_DATA => s_RegWrData,
    o_rs_DATA => s_ID_rs_DATA,
    o_rt_DATA => s_ID_rt_DATA);

  g_branch : branch --ID stage
  port map(
    i_branch_Sel => s_ID_branch_SEL, -- Selects which branch instruction evaluated
    i_rs         => s_ID_rs_DATA,
    i_rt         => s_ID_rt_DATA,
    o_branch     => s_ID_branch(0)); -- If 1, update PC with branch address. If 0, use PC + 4 for branch instructions

  g_extend : extend_16t32 --ID stage
  port map(
    i_A          => s_ID_IMM,
    i_nZero_Sign => s_ID_nZero_Sign(0),
    o_F          => s_ID_IMM_EXT
  );

  g_ALU : ALU --EX stage
  port map(
    i_nAdd_Sub  => s_EX_nAdd_Sub(0),
    i_shift_Sel => s_EX_shift_SEL,
    i_logic_Sel => s_EX_logic_SEL,
    i_out_Sel   => s_EX_out_SEL,
    i_rs        => s_EX_RS_DATA_MUX_FWD,
    i_rt        => s_EX_RT_DATA_MUX_FWD,
    i_shamt     => s_EX_SHAMT,
    o_overflow  => s_EX_overflow(0),
    o_rd        => s_EX_ALUOut
  );

  g_hazardDetection : hazardDetection
  port map(
    i_OPCODE         => s_ID_OPCODE,
    i_FUNCT          => s_ID_FUNCT,
    i_ID_RS_ADDR     => s_ID_rs_ADDR,
    i_ID_RT_ADDR     => s_ID_rt_ADDR,
    i_EX_RegWrAddr   => s_EX_RegWrAddr,
    i_DMEM_RegWrAddr => s_DMEM_RegWrAddr,
    i_EX_RegWr       => s_EX_RegWr,
    i_DMEM_RegWr     => s_DMEM_RegWr,
    i_branch         => s_ID_branch,
    i_branch_chk     => s_ID_branch_chk,
    i_LW_STALL       => s_LW_STALL,
    i_EX_halt        => s_EX_halt(0),
    i_DMEM_halt      => s_DMEM_halt(0),
    o_IF_ID_STALL    => s_IF_ID_STALL,
    o_ID_EX_STALL    => s_ID_EX_STALL,
    o_EX_DMEM_STALL  => s_EX_DMEM_STALL,
    o_DMEM_WB_STALL  => s_DMEM_WB_STALL,
    o_IF_ID_FLUSH    => s_IF_ID_FLUSH,
    o_ID_EX_FLUSH    => s_ID_EX_FLUSH,
    o_EX_DMEM_FLUSH  => s_EX_DMEM_FLUSH,
    o_DMEM_WB_FLUSH  => s_DMEM_WB_FLUSH,
    o_PC_STALL       => s_PC_STALL
  );

  g_forward : forward
  port map(
    i_EX_OPCODE          => s_EX_OPCODE,          -- Opcode, instruction[31:26]
    i_EX_FUNCT           => s_EX_FUNCT,           -- Function of R-type instruction
    i_EX_RS_ADDR         => s_EX_rs_ADDR,         -- RS address of instruction
    i_EX_RT_ADDR         => s_EX_rt_ADDR,         -- RT address of instruction
    i_DMEM_RegWrAddr     => s_DMEM_RegWrAddr,     -- destination address of instruction in Execute
    i_WB_RegWrAddr       => s_WB_RegWrAddr,       -- destination address of instruction in Data Memory
    i_DMEM_RegWr         => s_DMEM_RegWr(0),      -- destination write enable of instruction in Execute
    i_WB_RegWr           => s_WB_RegWr(0),        -- destination write enable of instruction in Data memory
    o_EX_RS_DATA_FWD_SEL => s_EX_RS_DATA_FWD_SEL, -- Active High (if one output 0 from buffer)
    o_EX_RT_DATA_FWD_SEL => s_EX_RT_DATA_FWD_SEL,
    o_DMEM_DATA_FWD_SEL  => s_DMEM_DATA_FWD_SEL,
    o_LW_HAZARD_CHK      => s_LW_STALL
  );

  -- Instruction Assignment
  s_NextInstAddr <= s_IF_PC;

  -- Mux for second ALU operand (EX stage)
  with s_EX_ALUSrc(0) select
  s_EX_rt_DATA_MUX <= s_EX_rt_DATA when '0',
    s_EX_IMM_EXT when others;

  -- Branch and Link regitster write control (EX)
  with s_EX_reg_WE_SEL(0) select
  s_EX_RegWr <= s_EX_reg_WE when '0',
    s_EX_branch when others;

  -- Mux for register file rd address (EX)
  with s_EX_reg_DST_ADDR_SEL select
    s_EX_RegWrAddr <= s_EX_rd_ADDR when "00",
    s_EX_rt_ADDR when "01",
    "11111" when others;

  -- RS ALU forwarding (EX)
  with s_EX_RS_DATA_FWD_SEL select
    s_EX_RS_DATA_MUX_FWD <= s_EX_rs_DATA when "00", --No forwarding
    s_DMEM_ALUout when "10", --Forward from DMEM
    s_RegWrData when others; --Forward from WB

  -- RT ALU forwarding (EX)
  with s_EX_RT_DATA_FWD_SEL select
    s_EX_RT_DATA_MUX_FWD <= s_EX_rt_DATA_MUX when "00", --No forwarding
    s_DMEM_ALUout when "10", --Forward from DMEM
    s_RegWrData when others; --Forward from WB

  with s_DMEM_DATA_FWD_SEL select
    s_EX_DMEM_DATA_MUX_FWD <= s_EX_rt_DATA when "00", --No forwarding, NO immediate :)
    s_DMEM_ALUout when "10", --Forward from DMEM
    s_RegWrData when others; --Forward from WB

  -- Mux for register file rd DATA (WB stage)
  with s_WB_reg_DST_DATA_SEL select
    s_RegWrData <= s_WB_ALUOut when "00",
    s_WB_DMEM_DATA when "01",
    s_WB_PC_4 when others; --R[31], $ra register for jal

  -- AND gate to output overflow indication for add and sub (WB stage)
  s_Ovfl <= s_WB_overflow_chk(0) and s_WB_overflow(0);

  --Dmem signal assignment 
  s_DMemAddr <= s_DMEM_ALUOut;
  s_DMemData <= s_DMEM_DMEM_DATA_MUX_FWD;

  -- Testbench assignments
  s_DMemWr <= s_DMEM_mem_WE(0);
  s_DMEM_DMEM_DATA <= s_DMemOut(31 downto 0);
  s_RegWr <= s_WB_RegWr(0);
  s_RegWrAddr <= s_WB_RegWrAddr;

  s_Halt <= s_WB_halt(0);

  -- SYNTH
  o_IF_Imem <= s_Inst;
  o_EX_ALUOut <= s_EX_ALUOut;
  o_EX_RegWrAddr <= s_EX_RegWrAddr;
  o_DMEM_DMEM_DATA <= s_DMEM_DMEM_DATA;
  o_WB_RegWrData <= s_RegWrData;
  o_EX_RegWr <= s_EX_RegWr(0);
  o_DMEM_mem_WE <= s_DMEM_mem_WE(0);

  o_halt <= s_WB_halt(0);
  o_overflow <= s_EX_overflow(0);

end mixed;