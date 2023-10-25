#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_extend_16t32.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_extend_16t32 unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 2/4/2023
#########################################################################

#Delete work folder
rm work -r

# compile all code in src folder 
vcom ../src/*.vhd
vcom ../src/testbench/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_extend_16t32

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /tb_extend_16t32/i_CLK
# add wave -noupdate -label Reset /tb_extend_16t32/i_RST

# Test Inputs
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix hexadecimal /tb_extend_16t32/i_A
add wave -noupdate -color magenta -radix unsigned /tb_extend_16t32/i_nZero_Sign

#Test outputs
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix hexadecimal /tb_extend_16t32/o_F

# Internal Test signals
# add wave -noupdate -divider {Test Signals}
# add wave -noupdate -color cyan -radix hexadecimal /tb_reg_file/s_RS_Expected

# Error checking signals
add wave -noupdate -divider {Error Checking}
add wave -noupdate -color red -radix hexadecimal /tb_extend_16t32/s_F_Expected
add wave -noupdate -color red -radix unsigned /tb_extend_16t32/s_F_Mismatch

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 100

# zoom fit to waves
wave zoom full

# wave cursors
# Waveform Screenshot 1
wave cursor add -time 15 -lock 1
wave cursor add -time 35 -lock 1
wave cursor add -time 55 -lock 1
wave cursor add -time 75 -lock 1