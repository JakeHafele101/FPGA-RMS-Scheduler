#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_ones_comp.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_ones_comp unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/22/2023
#########################################################################

# recompile all source code
vcom -2008 ../src/*.vhd

# start simulation
vsim -voptargs=+acc work.tb_ones_comp

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /FILENAME/CLK
# add wave -noupdate -label reset /FILENAME/reset

# Data Inputs
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -radix binary /tb_ones_comp/s_i_A 

# Data Outputs
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -radix binary /tb_ones_comp/s_o_F_DUT0
add wave -noupdate -radix binary /tb_ones_comp/s_o_F_DUT1
add wave -noupdate -radix binary /tb_ones_comp/s_o_F_DUT2

# error checking signals in testbench
# add wave -noupdate -divider {Testbench Signals}
# add wave -noupdate -radix unsigned /tb_ones_comp/s_DUT_select;

# Internal Design Signals
#add wave -noupdate -divider {Internal Design Signals}
#add wave -noupdate /tb_ones_comp/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 100

# zoom fit to waves
wave zoom full

