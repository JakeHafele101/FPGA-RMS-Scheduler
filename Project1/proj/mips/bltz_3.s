.data
.text
.globl main

# bltz $t0, label
# branch on less than zero - branch to label if $t0 < 0

# verify bltz does NOT branch to label when $t0 > 0
main:
addiu $t0, $0, 1 # initialize $t0 to a positive value
bltz $t0, exit # test that the program does not branch to exit
addiu $t0, $0, 100 # this instruction should run

exit:
halt # program exits with $t0 = 100