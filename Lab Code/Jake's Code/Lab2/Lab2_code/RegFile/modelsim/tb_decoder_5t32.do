#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_decoder_5t32.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_decoder_5t32 unit. It adds some useful signals for testing
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
vsim -voptargs=+acc work.tb_decoder_5t32

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /tb_decoder_5t32/s_CLK
# add wave -noupdate -label Reset /tb_decoder_5t32/s_RST

# Add data inputs that are specific to this design. These are the ones set during our test cases.
# Note that I've set the radix to unsigned, meaning that the values in the waveform will be displayed
# as unsigned decimal values. This may be more convenient for your debugging. However, you should be
# careful to look at the radix specifier (e.g., the decimal value 32'd10 is the same as the hexidecimal
# value 32'hA.
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_decoder_5t32/s_i_A
add wave -noupdate -color magenta -radix unsigned /tb_decoder_5t32/s_i_WE

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix hexadecimal /tb_decoder_5t32/s_o_F

# Test Inputs
# add wave -noupdate -divider {Test Signals}
# add wave -noupdate -color cyan -radix hexadecimal /tb_decoder_5t32/s_Q_Expected
# add wave -noupdate -color cyan -radix unsigned /tb_decoder_5t32/s_Q_Mismatch

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.
# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -radix unsigned /tb_decoder_5t32/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 2560

# zoom fit to waves
wave zoom full