#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_ripple_adder.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_ripple_adder unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/22/2023
#########################################################################

# compile all code in src folder 
vcom -2008 ../src/*.vhd
vcom -2008 ../src/testbench/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_ripple_adder

# Add the standard, non-data clock and reset input signals.
# add wave -noupdate -divider {Standard Inputs}
# add wave -noupdate -label CLK /FILENAME/CLK
# add wave -noupdate -label reset /FILENAME/reset

# Add data inputs that are specific to this design. These are the ones set during our test cases.
# Note that I've set the radix to unsigned, meaning that the values in the waveform will be displayed
# as unsigned decimal values. This may be more convenient for your debugging. However, you should be
# careful to look at the radix specifier (e.g., the decimal value 32'd10 is the same as the hexidecimal
# value 32'hA.
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -radix signed /tb_ripple_adder/s_i_X
add wave -noupdate -radix signed /tb_ripple_adder/s_i_Y
add wave -noupdate -radix unsigned /tb_ripple_adder/s_i_Cin

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -radix unsigned /tb_ripple_adder/s_o_Cout
add wave -noupdate -radix signed /tb_ripple_adder/s_o_S

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.
add wave -noupdate -divider {Internal Design Signals}
add wave -noupdate -radix unsigned /tb_ripple_adder/s_mismatch_S
add wave -noupdate -radix signed /tb_ripple_adder/s_expected_S
add wave -noupdate -radix unsigned /tb_ripple_adder/DUT0/s_C

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 180

# zoom fit to waves
wave zoom full