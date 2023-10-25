#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_adder_subber.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_adder_subber unit. It adds some useful signals for testing
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
vsim -voptargs=+acc work.tb_adder_subber

add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix signed /tb_adder_subber/i_A
add wave -noupdate -color magenta -radix signed /tb_adder_subber/i_B
add wave -noupdate -color magenta -radix unsigned /tb_adder_subber/i_nAdd_Sub

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix signed /tb_adder_subber/o_S
add wave -noupdate -color orange -radix unsigned /tb_adder_subber/o_overflow
add wave -noupdate -color orange -radix unsigned /tb_adder_subber/o_Cout

# Test Inputs
add wave -noupdate -divider {Expected Outputs}
add wave -noupdate -color cyan -radix signed /tb_adder_subber/s_S_expected
add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/s_overflow_expected
add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/s_Cout_expected

add wave -noupdate -divider {Error Checking}
add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/s_S_error
add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/s_overflow_error
add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/s_Cout_error

add wave -noupdate -divider {Operation}
add wave -noupdate -color red -radix ASCII /tb_adder_subber/s_OP_ASCII

# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/DUT0/g_branch/i_zero
# add wave -noupdate -color cyan -radix unsigned /tb_adder_subber/DUT0/g_add_sub/o_S


# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 100

# zoom fit to waves
wave zoom full

# wave cursors
# ADD
# wave cursor add -time 2 -lock 1
# wave cursor add -time 6 -lock 1
# wave cursor add -time 10 -lock 1
# wave cursor add -time 14 -lock 1
# wave cursor add -time 18 -lock 1
# wave cursor add -time 22 -lock 1
# wave cursor add -time 26 -lock 1
# wave cursor add -time 30 -lock 1
# wave cursor add -time 34 -lock 1
# wave cursor add -time 38 -lock 1
# wave cursor add -time 42 -lock 1
# wave cursor add -time 46 -lock 1

# SUB
wave cursor add -time 50 -lock 1
wave cursor add -time 54 -lock 1
wave cursor add -time 58 -lock 1
wave cursor add -time 62 -lock 1
wave cursor add -time 66 -lock 1
wave cursor add -time 70 -lock 1
wave cursor add -time 74 -lock 1
wave cursor add -time 78 -lock 1
wave cursor add -time 82 -lock 1
wave cursor add -time 86 -lock 1
wave cursor add -time 90 -lock 1
wave cursor add -time 94 -lock 1
wave cursor add -time 98 -lock 1