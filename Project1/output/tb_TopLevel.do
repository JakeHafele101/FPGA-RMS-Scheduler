#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 03/08/2023
#########################################################################

delete wave /tb/MyMips/*

add wave -noupdate -divider {General Inputs}
add wave -noupdate -color magenta -radix signed /tb/MyMips/iCLK
add wave -noupdate -color magenta -radix signed /tb/MyMips/iRST

# Internal Signals
add wave -noupdate -divider {Instruction Decode}
add wave -noupdate -color cyan -radix hexadecimal /tb/MyMips/s_Inst
add wave -noupdate -color cyan -radix unsigned /tb/MyMips/s_rd_ADDR

add wave -noupdate -divider {Control Input}
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_OPCODE
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_FUNCT

add wave -noupdate -divider {Control Output}
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_ALUSrc
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_overflow_chk
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_reg_DST_ADDR_SEL
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_reg_DST_DATA_SEL

add wave -noupdate -divider {Fetch Input}
add wave -noupdate -color orange -radix signed /tb/MyMips/s_J_ADDR
add wave -noupdate -color orange -radix unsigned /tb/MyMips/s_PC_SEL
add wave -noupdate -color orange -radix unsigned /tb/MyMips/s_branch_chk


add wave -noupdate -divider {Fetch Output}
add wave -noupdate -color orange -radix unsigned /tb/MyMips/s_NextInstAddr
add wave -noupdate -color orange -radix signed /tb/MyMips/s_PC_4

add wave -noupdate -divider {Register Input}
add wave -noupdate -color pink -radix unsigned /tb/MyMips/s_rt_ADDR
add wave -noupdate -color pink -radix unsigned /tb/MyMips/s_rs_ADDR
add wave -noupdate -color pink -radix signed /tb/MyMips/s_RegWrAddr
add wave -noupdate -color pink -radix signed /tb/MyMips/s_RegWrData
add wave -noupdate -color pink -radix unsigned /tb/MyMips/s_RegWr

add wave -noupdate -divider {Register Output}
add wave -noupdate -color pink -radix signed /tb/MyMips/s_rs_DATA
add wave -noupdate -color pink -radix signed /tb/MyMips/s_rt_DATA

add wave -noupdate -divider {Sign Extend}
add wave -noupdate -color "light green" -radix signed /tb/MyMips/s_IMM
add wave -noupdate -color "light green" -radix unsigned /tb/MyMips/s_nZero_Sign
add wave -noupdate -color "light green" -radix signed /tb/MyMips/s_IMM_EXT

add wave -noupdate -divider {ALU Input}
add wave -noupdate -color magenta -radix signed /tb/MyMips/s_rs_DATA
add wave -noupdate -color magenta -radix signed /tb/MyMips/s_rt_DATA_MUX
add wave -noupdate -color magenta -radix unsigned /tb/MyMips/s_SHAMT

add wave -noupdate -divider {ALU Output}
add wave -noupdate -color magenta -radix signed /tb/MyMips/oALUOut
add wave -noupdate -color magenta -radix unsigned /tb/MyMips/s_branch
add wave -noupdate -color magenta -radix unsigned /tb/MyMips/s_overflow

add wave -noupdate -divider {ALU Control}
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_nAdd_Sub
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_shift_SEL
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_branch_SEL
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_logic_SEL
add wave -noupdate -color red -radix unsigned /tb/MyMips/s_out_SEL

add wave -noupdate -divider {Data Memory Input}
add wave -noupdate -color "light blue" -radix hexadecimal /tb/MyMips/s_DMemAddr
add wave -noupdate -color "light blue" -radix signed /tb/MyMips/s_DMemData
add wave -noupdate -color "light blue" -radix unsigned /tb/MyMips/s_DMemWr


add wave -noupdate -divider {Data Memory Output}
add wave -noupdate -color "light blue" -radix unsigned /tb/MyMips/s_DMemOut



# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# zoom fit to waves
wave zoom full