#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_mux_32t1_32b.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_mux_32t1_32b unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/23/2023
#########################################################################

#Delete work folder
rm work -r

# compile all code in src folder 
vcom ../src/*.vhd
vcom ../src/testbench/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_mux_32t1_32b

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /tb_mux_32t1_32b/s_CLK
# add wave -noupdate -label Reset /tb_mux_32t1_32b/s_RST

# Add data inputs that are specific to this design. These are the ones set during our test cases.
# Note that I've set the radix to unsigned, meaning that the values in the waveform will be displayed
# as unsigned decimal values. This may be more convenient for your debugging. However, you should be
# careful to look at the radix specifier (e.g., the decimal value 32'd10 is the same as the hexidecimal
# value 32'hA.
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_mux_32t1_32b/s_i_S
add wave -noupdate -color magenta -radix hexadecimal /tb_mux_32t1_32b/s_i_D

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix hexadecimal /tb_mux_32t1_32b/s_o_O

# Test Inputs
# add wave -noupdate -divider {Test Signals}
add wave -noupdate -color cyan -radix hexadecimal /tb_mux_32t1_32b/s_Word

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.
# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -radix unsigned /tb_mux_32t1_32b/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 1280

# zoom fit to waves
wave zoom full