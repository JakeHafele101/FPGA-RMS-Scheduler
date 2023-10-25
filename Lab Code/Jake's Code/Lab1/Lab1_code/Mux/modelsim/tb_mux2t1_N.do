#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_mux2t1_N.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_mux2t1_N unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/20/2023
#########################################################################

# recompile all source code
vcom -2008 ../src/*.vhd

# start simulation
vsim -voptargs=+acc work.tb_mux2t1_n

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /FILENAME/CLK
# add wave -noupdate -label reset /FILENAME/reset

# Data Inputs
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_i_S 
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_i_D0
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_i_D1

# Data Outputs
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_o_O_DUT0
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_o_O_DUT1
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_o_O_DUT2


# error checking signals in testbench
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -radix unsigned /tb_mux2t1_N/s_DUT_select;

# Internal Design Signals
#add wave -noupdate -divider {Internal Design Signals}
#add wave -noupdate /tb_mux2t1_N/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 400

# zoom fit to waves
wave zoom full

