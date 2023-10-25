#########################################################################
## Thomas Gaul
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_Fetch.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_Control unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 03/02/2023
#########################################################################

# Mute warnings for numeric std conversion for int to logic vector
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Delete work folder
rm work -r

# compile all code in src folder 
vcom /*.vhd
vcom ../../src/fetch/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_Fetch

add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color red -radix unsigned /tb_Fetch/s_CLK
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_PC_RST
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_branch
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_branch_chk
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_PC_SEL
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_IMM_EXT
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_RS_DATA
add wave -noupdate -color orange -radix unsigned /tb_Fetch/s_J_ADDR

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color white -radix hexadecimal /tb_Fetch/s_PC
add wave -noupdate -color white -radix hexadecimal /tb_Fetch/s_PC_4



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

