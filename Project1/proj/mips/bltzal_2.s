#bltzal test case 2 (test with large negative number)
#Tests that the processor can branch when the value is less then zero and link back to the next instruction

addi $t0, $t0, -290000 #Add -290000 to $t0

bltzal $t0, Negative #Branches to negative when $t0 is negative

addi $t1, $zero, 1 #After branching adss 1 to $t1 this is used to show if it worked

j end #ends

Negative:

addi $t0, $zero, 1 #Sets $t0 to 1 this values shows it worked

jr $ra #Verifies the link portion works and the instruction after branch is saved

end: 

#worked properly if $t0 is 1 and $t1 is 1
halt
