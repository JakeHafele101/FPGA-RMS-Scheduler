#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_dmem.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_dmem unit. It adds some useful signals for testing
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
vcom ../../RegFile/src/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_dmem

#Load dmem.hex file for memory
mem load -infile dmem.hex -format hex /tb_dmem/DUT0/ram

# Add the standard, non-data clock and reset input signals.
add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb_dmem/i_CLK
# add wave -noupdate -label Reset /tb_dmem/i_RST

# Test Inputs
add wave -noupdate -divider {Data Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_dmem/i_ADDR
add wave -noupdate -color magenta -radix signed /tb_dmem/i_DATA
add wave -noupdate -color magenta -radix unsigned /tb_dmem/i_WE

#Test outputs
add wave -noupdate -divider {Data Outputs}
add wave -noupdate -color orange -radix signed /tb_dmem/o_Q

# Internal Test signals
# add wave -noupdate -divider {Test Signals}
# add wave -noupdate -color cyan -radix hexadecimal /tb_reg_file/s_RS_Expected

# Error checking signals
add wave -noupdate -divider {Error Checking}
add wave -noupdate -color red -radix signed /tb_dmem/s_Q_Expected
add wave -noupdate -color red -radix unsigned /tb_dmem/s_Q_Mismatch

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 630

# zoom fit to waves
wave zoom full

# wave cursors
# Waveform Screenshot 1
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

# Waveform Screenshot 2
# wave cursor add -time 215 -lock 1
# wave cursor add -time 235 -lock 1
# wave cursor add -time 255 -lock 1
# wave cursor add -time 275 -lock 1
# wave cursor add -time 295 -lock 1
# wave cursor add -time 315 -lock 1
# wave cursor add -time 335 -lock 1
# wave cursor add -time 355 -lock 1
# wave cursor add -time 375 -lock 1
# wave cursor add -time 395 -lock 1

# Waveform Screenshot 2
wave cursor add -time 415 -lock 1
wave cursor add -time 435 -lock 1
wave cursor add -time 455 -lock 1
wave cursor add -time 475 -lock 1
wave cursor add -time 495 -lock 1
wave cursor add -time 515 -lock 1
wave cursor add -time 535 -lock 1
wave cursor add -time 555 -lock 1
wave cursor add -time 575 -lock 1
wave cursor add -time 595 -lock 1