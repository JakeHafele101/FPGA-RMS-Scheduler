# Test positive values for bgtz
# This test case covers the common case where:
# $s register contains a positive value
# immediate value is a positive value

# Initialize $s0 to a positive value
addi $s0, $zero, 5

# Test case 1: $s0 = 5, immediate value = 3
bgtz $s0, label1
nop
label1:
nop

# Test case 2: $s0 = 5, immediate value = 10
bgtz $s0, label2
nop
label2:
nop

# Test case 3: $s0 = 100, immediate value = 50
li $s0, 100
bgtz $s0, label3
nop
label3:
nop
halt
