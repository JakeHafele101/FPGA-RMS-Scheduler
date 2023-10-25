.data
.text
.globl main
main:
# This test is an edge case to see if you can jr if the register holds the first possible address of an instruction
#It is important to see if you can jump to begging of code
    # Start Test
    beq $2,1,end #First Instruction at 0x00400000
    lui $1, 0x0040 # Loading edge case of initial program memory location
    addi $2,$0,1 # Change beq to true
    jr $1 #Jump to the initial program memory location
    # End Test
	end:
    # Exit program
    halt
