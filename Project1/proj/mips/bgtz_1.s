# Test edge cases for bgtz
# This test case covers the edge cases where:
# $s register is 0
# $s register is the maximum value
# immediate value is 0
# immediate value is the maximum positive value

# Initialize $s0 to 0
addi $s0, $zero, 0

# Test case 1: $s0 = 0, immediate value = 0
bgtz $s0, label1
nop
label1:
nop

# Test case 2: $s0 = 0, immediate value = max positive value
li $t0, 2147483647
bgtz $s0, label2
nop
label2:
nop

# Initialize $s0 to the maximum value
li $s0, 2147483647

# Test case 3: $s0 = max value, immediate value = 0
bgtz $s0, label3
nop
label3:
nop

# Test case 4: $s0 = max value, immediate value = max positive value
li $t0, 2147483647
bgtz $s0, label4
nop
label4:
nop
halt
