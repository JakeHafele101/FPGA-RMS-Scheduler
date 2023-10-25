#pc counter starts at 0x00400000
jal exit

exit:
#$ra should hold the value 0x00400004 which is pc + 4, store it in $t0
addi $t0, $ra, 0

halt

#why am I including this test
#I am including this test to make sure the that the ra is gettin the value from the pc + 4
#why does the text have value
# this test has value becasue it ensures that the $ra gets the value from the pc + 4 (the next instruction) and as
#such you are able to return when you need to