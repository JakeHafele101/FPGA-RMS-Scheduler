#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_second_datapath.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_second_datapath unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 02/7/2023
#########################################################################

#Delete work folder
rm work -r

# compile all code in src folder 
vcom ../src/*.vhd
vcom ../src/testbench/*.vhd
vcom ../../RegFile/src/*.vhd
vcom ../../Extenders/src/*.vhd
vcom ../../MyFirstMIPSDatapath/src/*.vhd
vcom ../../Memory/src/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_second_datapath

#Load dmem.hex file for memory
mem load -infile dmem.hex -format hex /tb_second_datapath/DUT0/g_dmem/ram

# Add the standard, non-data clock and reset input signals.
add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb_second_datapath/i_CLK
add wave -noupdate -label Reset /tb_second_datapath/i_RST

# Add data inputs that are specific to this design. These are the ones set during our test cases.
# Note that I've set the radix to unsigned, meaning that the values in the waveform will be displayed
# as unsigned decimal values. This may be more convenient for your debugging. However, you should be
# careful to look at the radix specifier (e.g., the decimal value 32'd10 is the same as the hexidecimal
# value 32'hA.
# add wave -noupdate -divider {Data Inputs}
add wave -noupdate -divider {Reg Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_RS
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_RT
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_RD
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_RD_WE
add wave -noupdate -divider {Adder Inputs}
add wave -noupdate -color magenta -radix signed /tb_second_datapath/i_IMM
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_nAdd_Sub
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_ALU_SRC
add wave -noupdate -divider {Memory Inputs}
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_SW
add wave -noupdate -color magenta -radix unsigned /tb_second_datapath/i_nADDER_MEM


# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Internal Signals}
add wave -noupdate -color orange -radix signed /DUT0/s_RS_DATA
add wave -noupdate -color orange -radix signed /DUT0/s_RT_DATA
add wave -noupdate -color orange -radix signed /DUT0/s_ARITH_DATA
add wave -noupdate -color orange -radix signed /DUT0/s_MEM_DATA
add wave -noupdate -color orange -radix signed /DUT0/s_IMM_32B

add wave -noupdate -divider {Internal MUX Signals}
add wave -noupdate -color orange -radix signed /DUT0/s_RD_DATA_MUX

# Test Inputs
add wave -noupdate -divider {Instruction}
add wave -noupdate -color cyan -radix ASCII /tb_second_datapath/s_INSTR_NAME

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.
# add wave -noupdate -divider {Internal Design Signals}
# add wave -noupdate -radix unsigned /tb_second_datapath/DUT0/*

# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 720

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
# wave cursor add -time 215 -lock 1

# Waveform Screenshot 2
# wave cursor add -time 235 -lock 1
# wave cursor add -time 255 -lock 1
# wave cursor add -time 275 -lock 1
# wave cursor add -time 295 -lock 1
# wave cursor add -time 315 -lock 1
# wave cursor add -time 335 -lock 1
# wave cursor add -time 355 -lock 1
# wave cursor add -time 375 -lock 1
# wave cursor add -time 395 -lock 1
# wave cursor add -time 415 -lock 1
# wave cursor add -time 435 -lock 1

# Waveform screenshot 3 (array A checking)
wave cursor add -time 455 -lock 1
wave cursor add -time 475 -lock 1
wave cursor add -time 495 -lock 1
wave cursor add -time 515 -lock 1
wave cursor add -time 535 -lock 1
wave cursor add -time 555 -lock 1
wave cursor add -time 575 -lock 1

# Waveform screenshot 3 (array B checking)
wave cursor add -time 595 -lock 1
wave cursor add -time 615 -lock 1
wave cursor add -time 635 -lock 1
wave cursor add -time 655 -lock 1
wave cursor add -time 675 -lock 1
wave cursor add -time 695 -lock 1
wave cursor add -time 715 -lock 1