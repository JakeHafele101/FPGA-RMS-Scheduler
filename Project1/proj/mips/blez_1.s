# blez - Branch if less than or equal to Z.

# This file tests the normal operating cases of the blez function.
# Tests <0, =0, >0

.data
str1: .asciiz "I'm a little Teapot, short and stout."
str2: .asciiz "Tests passed!"
.text
# Normal cases
	# * Input > 0
	addi $t0, $0, 100
	blez $t0, fail

oops:	# * Input == 0
	add $t0, $0, $0
	blez $t0, yay

	j fail
	
yay:	# * Input < 0
	addi $t0, $0, -100
	blez $t0, complete
	
complete:	
	# Print complete -------------------------------
	li 	$v0, 4		# Read integer
	la 	$a0, str2	# Set result
	syscall			# Do the kernel thing
	halt

fail:	# Print teapot -------------------------------
	li 	$v0, 4		# Read integer
	la 	$a0, str1	# Set result
	syscall			# Do the kernel thing
	halt
