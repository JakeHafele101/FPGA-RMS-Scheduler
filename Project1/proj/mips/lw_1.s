.data
test: .word 2
.text
.globl main
main:
	# This test verifies edge case usage of the lw instruction (instructions that 
	# load memory from addresses on the very edges of the data memory). 
	
	# The address of 0x000003fc was chosen to reach the extreme edge
	# of the 10-bit addressed data memory module.
	
	# Successfully testing that these "extreme case" operations are properly 
	# executed could ensure that critical issues (that might otherwise have taken 
	# weeks to discover) aren't present.
	
	# Start Test
        la $t0, test

	lw $t4, 0($t0)			# execute lw instruction
	
	
	# End Test
	
	
	# Exit Program
	li $v0, 10
	syscall
	
        halt
