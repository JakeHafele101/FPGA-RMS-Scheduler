#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_reg_file.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_reg_file unit. It adds some useful signals for testing
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
vsim -voptargs=+acc work.tb_reg_file

# Add the standard, non-data clock and reset input signals.
add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb_reg_file/s_CLK
add wave -noupdate -label Reset /tb_reg_file/s_RST

# Add data inputs that are specific to this design. These are the ones set during our test cases.
# Note that I've set the radix to unsigned, meaning that the values in the waveform will be displayed
# as unsigned decimal values. This may be more convenient for your debugging. However, you should be
# careful to look at the radix specifier (e.g., the decimal value 32'd10 is the same as the hexidecimal
# value 32'hA.
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_reg_file/s_i_RS
add wave -noupdate -color magenta -radix unsigned /tb_reg_file/s_i_RT
add wave -noupdate -color magenta -radix unsigned /tb_reg_file/s_i_RD
add wave -noupdate -color magenta -radix unsigned /tb_reg_file/s_i_RD_WE
add wave -noupdate -color magenta -radix hexadecimal /tb_reg_file/s_i_RD_DATA

# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix hexadecimal /tb_reg_file/s_o_RS_DATA
add wave -noupdate -color orange -radix hexadecimal /tb_reg_file/s_o_RT_DATA

# Test Inputs
add wave -noupdate -divider {Test Signals}
add wave -noupdate -color cyan -radix hexadecimal /tb_reg_file/s_RS_Expected
add wave -noupdate -color cyan -radix hexadecimal /tb_reg_file/s_RT_Expected


add wave -noupdate -divider {Error Checking}
add wave -noupdate -color red -radix hexadecimal /tb_reg_file/s_RS_Mismatch
add wave -noupdate -color red -radix hexadecimal /tb_reg_file/s_RT_Mismatch

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.
# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -radix unsigned /tb_reg_file/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 120

# zoom fit to waves
wave zoom full

#add wave cursors
wave cursor add -time 15 -lock 1
wave cursor add -time 35 -lock 1
wave cursor add -time 55 -lock 1
wave cursor add -time 75 -lock 1
wave cursor add -time 95 -lock 1
wave cursor add -time 115 -lock 1
wave cursor see -at 100