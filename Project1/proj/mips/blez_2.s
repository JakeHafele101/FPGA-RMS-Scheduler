# This file tests the edge operating cases of the blez function.
# Tests max/min int representation

.data
str1: .asciiz "I'm a little Teapot, short and stout."
str2: .asciiz "Tests passed!"
.text

# Edge cases
# * Input = Representation Max
	addi $t1, $0, 1073741823
	addi $t1, $t1, 1073741824
	blez $t1, fail

# * Input = Representation Min
	addi $t2, $0, -1073741824
	addi $t2, $t2, -1073741824
	blez $t2, complete

	j fail

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
