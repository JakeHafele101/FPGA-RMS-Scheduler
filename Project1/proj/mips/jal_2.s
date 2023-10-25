#check that the jump part of jal works
#0s out $t0
add $t0, $0, $0
jal exit

#if we fail to jump $t0 will get set to 5, if we suceed it should be 0
addi $t0, $0, 5

exit:
halt

#why am I including this test
#I am including this test to ensure that the jump part of the jal works
#why does the test have value
#this test is important, becasue it makes sure that we acstually jump to our desination. If we can't jump then
# we dont need to somewhere to go back since we neve left