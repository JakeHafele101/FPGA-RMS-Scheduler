#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_mux2t1_behav.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_mux2t1_behav unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/20/2023
#########################################################################

# recompile all source code
vcom -2008 ../src/*.vhd

# start testbench simulation
vsim work.tb_mux2t1_behav

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /FILENAME/CLK
# add wave -noupdate -label reset /FILENAME/reset

# data inputs of top module
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -radix unsigned /tb_mux2t1_behav/s_i_S
add wave -noupdate -radix unsigned /tb_mux2t1_behav/s_i_D1
add wave -noupdate -radix unsigned /tb_mux2t1_behav/s_i_D0

# data outputs of top module
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -radix unsigned /tb_mux2t1_behav/s_o_O

# internal signals to modules (use /* to include all, or specify after /DUT#/)
# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate /tb_mux2t1_behav/DUT0/*

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 2000

# zoom fit to waves
wave zoom full