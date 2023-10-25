.data
.text
.globl main
main:
# This test is common case to see if jr will jump with relation to the $ra register
# Output should have $v0 as 6
# testing $ra because most common register used with jr


#start Test
addi $a0,$0,5
jal foo

  #v0 should be 6
      # Exit program
  halt


#Jal
foo:
addiu $v0, $a0,1
jr $ra #Important peice
    
