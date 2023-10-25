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

addiu $t9, $zero, 0xFFFFFFFF		# Set $t9 to 0xFFFFFFFF as our "reset" to 0

# NOR Each Register to 0
nor $s0, $t9, $t1
nor $s1, $t9, $t2
nor $s2, $t9, $t3
nor $s3, $t9, $t4
nor $s4, $t9, $t5
nor $s5, $t9, $t6
nor $s6, $t9, $t7
# For each of the tests above, we wanted to see and ensure we could use NOR to properly "reset" our register to 0. 
halt
