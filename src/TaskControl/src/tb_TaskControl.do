#Delete work folder
rm work -r

# compile all code in src folder 
vcom ../src/*.vhd
vcom ../../RippleAdder/src/*.vhd
# start simulation with all signals shown
vsim -voptargs=+acc work.tb_TaskControl


add wave -noupdate -radix signed /tb_TaskControl/*

# Add some internal signals. As you debug you will likely want to trace the origin of signals
# back through your design hierarchy which will require you to add signals from within sub-components.
# These are provided just to illustrate how to do this. Note that any signals that are not added to
# the wave prior to the run command may not have their values stored during simulation. Therefore, if
# you decided to add them after simulation they will appear as blank.
# Note that I've left the radix of these signals set to the default, which, for me, is hexidecimal.

#add wave -noupdate -radix unsigned /tb_TaskControl/*


# toggle leaf name to off (only see one level)
config wave -signalnamewidth 1

# Run for X timesteps (default is 1ns per timestep, but this can be modified so be aware).
run 800

# zoom fit to waves
wave zoom full