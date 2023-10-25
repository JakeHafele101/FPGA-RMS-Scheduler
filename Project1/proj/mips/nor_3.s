# Brendon Droege
# CprE 381 - Homework 04 - Spring 2023

# We used an instruction above mine to play around with NOR more effectively.

addiu $t1, $zero, 0xFFFFFFFF		# Set $t1 to 0xFFFFFFFF
addiu $t2, $zero, 0x00000000		# Set $t2 to 0x00000000	
addiu $t3, $zero, 0x1234abcd		# Set $t3 to 0x1234abcd
addiu $t4, $zero, 0xF00F0990		# Set $t4 to 0xF00F0990
addiu $t5, $zero, 0x91382423		# Set $t5 to 0x91382423
addiu $t6, $zero, 0x10101010		# Set $t6 to 0x10101010
addiu $t7, $zero, 0xcdab9876		# Set $t7 to 0xcdab9876

addiu $t8, $zero, 0x00000000		# Set $t8 to 0x00000000 as our "clean" 0 slate
addiu $t9, $zero, 0xFFFFFFFF		# Set $t9 to 0xFFFFFFFF as our "reset" to 0

# There will be no overflow or real concerns of exceptions as NOR merely looks at the bits and compares them as 1's and 0's

# Let's build up a train of NOR statements and then ensure we can eventually reset.
nor $1, $t3, $t4
nor $2, $1, $t5
nor $3, $2, $t6
nor $4, $3, $t7
nor $5, $4, $t2
nor $6, $2, $3
nor $7, $4, $6
nor $8, $t3, $7
nor $9, $8, $t5
nor $10, $9, $t4
nor $11, $10, $t3
nor $12, $11, $t9			## Our reset, $12 should be 0

# For the tests above, we wanted to show how the "train" of taking the original register and inputting it to the next one and continuing
# that pattern to show how the bitwise operations don't overflow, don't have exceptions, and are easily manipulated.
halt 
