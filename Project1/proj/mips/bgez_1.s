addi $t0, $zero, 1
bgez $t1, backward_branch

label:
bgez $t0, end

backward_branch:
# check that the instruction can branch backwards
bgez $t0, label

end:
halt
