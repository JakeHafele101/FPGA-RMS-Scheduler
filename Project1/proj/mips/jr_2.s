.data
.text
.globl main
main:
# This test is a common casee to see if you can jrto arnadom locaiton in instruction memory
## What is expected to happen is that 
##Runs as expecteted until jr $10 , which it jumps to the addiu $10,$10,0x00c line because that is at 0x004000c which is value of $10
#$10 is now 0x00400018 , which is instruction line of halt stopping code


    # Start Test
    beq $2,1,end #NOP not important to case
   
    lui $10, 0x0040
    addiu $10, $10,0x000c # Loading 0x0004000c to see if you can jump to random location in instuction memory
    
    addi $2,$0,1 # MOP
    jr $10 #Jump to the initial program memory location
    # End Test
	end: #NOT USED IN THIS EXAMPLE
    # Exit program
    halt