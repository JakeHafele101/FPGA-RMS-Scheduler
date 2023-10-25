#########################################################################
## Thomas Gaul
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_ALU.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_Control unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 03/01/2023
#########################################################################

# Mute warnings for numeric std conversion for int to logic vector
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Delete work folder
rm work -r

# compile all code in src folder 
vcom /*.vhd
vcom ../../src/control/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_Control

add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix binary /tb_Control/s_OPCODE
add wave -noupdate -color magenta -radix binary /tb_Control/s_FUNCT
add wave -noupdate -color magenta -radix binary /tb_Control/s_RT_ADDR

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix unsigned /tb_Control/s_halt
add wave -noupdate -color orange -radix unsigned /tb_Control/s_extend_nZero_Sign
add wave -noupdate -color orange -radix unsigned /tb_Control/s_ALUSrc
add wave -noupdate -color orange -radix unsigned /tb_Control/s_overflow_chk
add wave -noupdate -color orange -radix unsigned /tb_Control/s_branch_chk
add wave -noupdate -color orange -radix unsigned /tb_Control/s_reg_WE
add wave -noupdate -color orange -radix unsigned /tb_Control/s_mem_WE
add wave -noupdate -color orange -radix unsigned /tb_Control/s_nAdd_Sub
add wave -noupdate -color orange -radix unsigned /tb_Control/s_reg_DST_ADDR_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_reg_DST_DATA_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_PC_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_shift_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_logic_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_out_SEL
add wave -noupdate -color orange -radix unsigned /tb_Control/s_branch_SEL

# Test Inputs
add wave -noupdate -divider {Expected Outputs}
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_halt
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_extend_nZero_Sign
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_ALUSrc
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_overflow_chk
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_branch_chk
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_reg_WE
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_mem_WE
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_nAdd_Sub
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_reg_DST_ADDR_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_reg_DST_DATA_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_PC_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_shift_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_logic_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_out_SEL
add wave -noupdate -color cyan -radix unsigned /tb_Control/c_branch_SEL

add wave -noupdate -divider {Check Signals}
add wave -noupdate -color orange -radix unsigned /tb_Control/s_error

add wave -noupdate -divider {Operation}
add wave -noupdate -color red -radix ASCII /tb_Control/s_OP_ASCII

add wave -noupdate -divider {Internal Design Signals}
#add wave -noupdate -color magenta -radix unsigned /tb_Control/DUT0/i_OPCODE


# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 675

# zoom fit to waves
wave zoom full

# wave cursors
# wave cursor add -time 15 -lock 1
# wave cursor add -time 35 -lock 1
# wave cursor add -time 55 -lock 1
# wave cursor add -time 75 -lock 1
# wave cursor add -time 95 -lock 1
# wave cursor add -time 115 -lock 1
# wave cursor add -time 135 -lock 1
# wave cursor add -time 155 -lock 1
# wave cursor add -time 175 -lock 1
# wave cursor add -time 195 -lock 1
# wave cursor add -time 215 -lock 1

