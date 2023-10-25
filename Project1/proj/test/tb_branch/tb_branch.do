#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_branch.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_branch unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 02/27/2023
#########################################################################

# Mute warnings for numeric std conversion for int to logic vector
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Delete work folder
rm work -r

# compile all code in src folder 
vcom /*.vhd
vcom ../../src/ALU/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_branch

add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix signed /tb_branch/i_rs
add wave -noupdate -color magenta -radix hexadecimal /tb_branch/i_branch_Sel
add wave -noupdate -color magenta -radix unsigned /tb_branch/i_zero

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix unsigned /tb_branch/o_branch

# Test Inputs
add wave -noupdate -divider {Expected Outputs}
add wave -noupdate -color cyan -radix unsigned /tb_branch/s_branch_expected

add wave -noupdate -divider {Error Checking}
add wave -noupdate -color cyan -radix unsigned /tb_branch/s_branch_error

add wave -noupdate -divider {Operation}
add wave -noupdate -color red -radix ASCII /tb_branch/s_OP_ASCII

# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -color cyan -radix unsigned /tb_branch/DUT0/g_branch/i_zero
# add wave -noupdate -color cyan -radix unsigned /tb_branch/DUT0/g_add_sub/o_S


# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 200

# zoom fit to waves
wave zoom full

# wave cursors
# BEQ/BNE
# wave cursor add -time 2 -lock 1
# wave cursor add -time 6 -lock 1
# wave cursor add -time 10 -lock 1
# wave cursor add -time 14 -lock 1

# BGEZ/BGTZ
# wave cursor add -time 18 -lock 1
# wave cursor add -time 22 -lock 1
# wave cursor add -time 26 -lock 1
# wave cursor add -time 30 -lock 1
# wave cursor add -time 34 -lock 1
# wave cursor add -time 38 -lock 1
# wave cursor add -time 42 -lock 1
# wave cursor add -time 46 -lock 1
# wave cursor add -time 50 -lock 1
# wave cursor add -time 54 -lock 1
# wave cursor add -time 58 -lock 1
# wave cursor add -time 62 -lock 1

# BLEZ/BLTZ
# wave cursor add -time 66 -lock 1
# wave cursor add -time 70 -lock 1
# wave cursor add -time 74 -lock 1
# wave cursor add -time 78 -lock 1
# wave cursor add -time 82 -lock 1
# wave cursor add -time 86 -lock 1
# wave cursor add -time 90 -lock 1
# wave cursor add -time 94 -lock 1
# wave cursor add -time 98 -lock 1
# wave cursor add -time 102 -lock 1
# wave cursor add -time 106 -lock 1
# wave cursor add -time 110 -lock 1

# BGZL/BLZL
wave cursor add -time 114 -lock 1
wave cursor add -time 118 -lock 1
wave cursor add -time 122 -lock 1
wave cursor add -time 126 -lock 1
wave cursor add -time 130 -lock 1
wave cursor add -time 134 -lock 1
wave cursor add -time 138 -lock 1
wave cursor add -time 142 -lock 1
wave cursor add -time 146 -lock 1
wave cursor add -time 150 -lock 1
wave cursor add -time 154 -lock 1
wave cursor add -time 158 -lock 1