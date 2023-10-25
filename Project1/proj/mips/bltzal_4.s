#bltzal test case 4 (test with positive number, should not branch)
#Tests that the processor can branch when the value is less then zero and link back to the next instruction

addi $t0, $t0, 25 #Add -2900 to $t0

bltzal $t0, Negative #Branches to negative when $t0 is negative

addi $t1, $zero, 1 #After branching adss 1 to $t1 this is used to show if it worked

j end #ends

Negative:

addi $t0, $t0, 1 #Sets $t0 to 1 this values shows it worked

jr $ra #Verifies the link portion works and the instruction after branch is saved

end: 

#worked properly if $t0 is 25 and $t1 is 1
halt
