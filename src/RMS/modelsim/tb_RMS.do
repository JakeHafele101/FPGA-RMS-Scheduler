#########################################################################
## Jake Hafele
## Department of Electrical and Computer Engineering
## Iowa State University
#########################################################################
## tb_RMS.do
#########################################################################
## DESCRIPTION: This file contains a do file for the testbench for the 
##              tb_RMS unit. It adds some useful signals for testing
##              functionality and debugging the system. It also formats
##              the waveform and runs the simulation.
##              
## Created 01/23/2023
#########################################################################

#Delete work folder
rm work -r

# compile all code in src folder 
vcom ../src/*.vhd
vcom ../../3t8Decoder/src/*.vhd
vcom ../../8t1MUX32b/src/*.vhd
vcom ../../32BitDFF/src/*.vhd
vcom ../../RippleAdder/src/*.vhd
vcom ../../TaskControl/src/*.vhd
vcom ../../TaskStateReg/src/*.vhd
vcom ../../TimerCounter/src/*.vhd

# start simulation with all signals shown
vsim -voptargs=+acc work.tb_RMS

# Add the standard, non-data clock and reset input signals.
add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb_RMS/s_CLK
add wave -noupdate -label Reset /tb_RMS/s_RST
add wave -noupdate -label Reset /tb_RMS/s_dffN_incr
add wave -noupdate -label Reset /tb_RMS/s_PC_incr


# Add data outputs that are specific to this design. These are the ones that we'll check for correctness.
add wave -noupdate -divider {Control Outputs}
add wave -noupdate -color orange -radix unsigned /tb_RMS/o_time
add wave -noupdate -color orange -radix binary /tb_RMS/o_LCMclear
add wave -noupdate -color orange -radix binary /tb_RMS/o_Current_Task_Sel
add wave -noupdate -color orange -radix binary /tb_RMS/o_Current_Task_Sel_WE

add wave -noupdate -divider {Task State Outputs}
add wave -noupdate -color green -radix binary /tb_RMS/o_task_period_clear
add wave -noupdate -color green -radix binary /tb_RMS/o_task_isComplete

add wave -noupdate -divider {Task Current PC Outputs}
add wave -noupdate -color cyan -radix unsigned /tb_RMS/o_task0_currentPC
add wave -noupdate -color cyan -radix unsigned /tb_RMS/o_task1_currentPC
add wave -noupdate -color cyan -radix unsigned /tb_RMS/o_task2_currentPC
add wave -noupdate -color cyan -radix unsigned /tb_RMS/o_task3_currentPC
add wave -noupdate -color cyan -radix unsigned /tb_RMS/o_task0_currentPC

add wave -noupdate -divider {Task dffN Outputs}
add wave -noupdate -color pink -radix unsigned /tb_RMS/o_task0_dffN_Q
add wave -noupdate -color pink -radix unsigned /tb_RMS/o_task1_dffN_Q
add wave -noupdate -color pink -radix unsigned /tb_RMS/o_task2_dffN_Q
add wave -noupdate -color pink -radix unsigned /tb_RMS/o_task3_dffN_Q
add wave -noupdate -color pink -radix unsigned /tb_RMS/o_task4_dffN_Q


# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 650

# zoom fit to waves
wave zoom full