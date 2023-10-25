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
	

nor $s0, $t1, $zero			# Verify that $t1 NOR with $zero = 00000000 and stored in $s0
nor $s1, $zero, $t1			# Verify that $zero NOR with $t1 = 00000000 and stored in $s1
nor $s2, $t1, $t3			# Verify that $t1 NOR with $t3 = 00000000 and stored in $s2
nor $s3, $t3, $t5			# Verify that $t3 NOR with $t5 = 0x6CC35010 and stored in $s3
nor $s4, $t5, $t7			# Verify that $t5 NOR with $t7 = 0x224444388 and stored in $s4
nor $s5, $t7, $t6			# Verify that $t7 NOR with $t6 = 0x22446789 and stored in $s5
nor $s6, $t6, $t4			# Verify that $t6 NOR with $t4 = 0x0FE0E66F and stored in $s6
nor $s7, $t4, $t2			# Verify that $t4 NOR with $t2 = 0x0FF0F66F and stored in $s7

# Now flip the two source registers

nor $s2, $t3, $t1			
nor $s3, $t5, $t3			
nor $s4, $t7, $t5			
nor $s5, $t6, $t7			
nor $s6, $t4, $t6			
nor $s7, $t2, $t4
			
# The purpose of these tests were to just play around with the NOR operation, and ensure it could
# handle a plethora of odd and weird numbers. These tests were design to test the "general" mechanism
# and correction of the NOR operation. 
halt
