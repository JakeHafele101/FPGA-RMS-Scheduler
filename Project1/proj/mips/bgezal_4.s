# Stress testing if all registers can be bgezaled, this is same as 0xFFFF.FFFF just for my sanity check

addiu	$1, $0, 4294967295	# Testing if it brances on < 0
addiu	$2, $0, 4294967295	# Testing if it brances on < 0
addiu	$3, $0, 4294967295	# Testing if it brances on < 0
addiu	$4, $0, 4294967295	# Testing if it brances on < 0
addiu	$5, $0, 4294967295	# Testing if it brances on < 0
addiu	$6, $0, 4294967295	# Testing if it brances on < 0
addiu	$7, $0, 4294967295	# Testing if it brances on < 0
addiu	$8, $0, 4294967295	# Testing if it brances on < 0
addiu	$9, $0, 4294967295	# Testing if it brances on < 0
addiu	$10, $0, 4294967295	# Testing if it brances on < 0
addiu	$11, $0, 4294967295	# Testing if it brances on < 0
addiu	$12, $0, 4294967295	# Testing if it brances on < 0
addiu	$13, $0, 4294967295	# Testing if it brances on < 0
addiu	$14, $0, 4294967295	# Testing if it brances on < 0
addiu	$15, $0, 4294967295	# Testing if it brances on < 0
addiu	$16, $0, 4294967295	# Testing if it brances on < 0
addiu	$17, $0, 4294967295	# Testing if it brances on < 0
addiu	$18, $0, 4294967295	# Testing if it brances on < 0
addiu	$19, $0, 4294967295	# Testing if it brances on < 0
addiu	$20, $0, 4294967295	# Testing if it brances on < 0
addiu	$21, $0, 4294967295	# Testing if it brances on < 0
addiu	$22, $0, 4294967295	# Testing if it brances on < 0
addiu	$23, $0, 4294967295	# Testing if it brances on < 0
addiu	$24, $0, 4294967295	# Testing if it brances on < 0
addiu	$25, $0, 4294967295	# Testing if it brances on < 0
addiu	$26, $0, 4294967295	# Testing if it brances on < 0
addiu	$27, $0, 4294967295	# Testing if it brances on < 0
addiu	$28, $0, 4294967295	# Testing if it brances on < 0
addiu	$29, $0, 4294967295	# Testing if it brances on < 0
addiu	$30, $0, 4294967295	# Testing if it brances on < 0
addiu	$31, $0, 4294967295	# Testing if it brances on < 0

bgezal	$1, _R_1
_not_R_1:
	j		_ames				# jump to _ames
_R_1:
bgezal	$2, _R_2
_not_R_2:
	j		_ames				# jump to _ames
_R_2:
bgezal	$3, _R_3
_not_R_3:
	j		_ames				# jump to _ames
_R_3:
bgezal	$4, _R_4
_not_R_4:
	j		_ames				# jump to _ames
_R_4:
bgezal	$5, _R_5
_not_R_5:
	j		_ames				# jump to _ames
_R_5:
bgezal	$6, _R_6
_not_R_6:
	j		_ames				# jump to _ames
_R_6:
bgezal	$7, _R_7
_not_R_7:
	j		_ames				# jump to _ames
_R_7:
bgezal	$8, _R_8
_not_R_8:
	j		_ames				# jump to _ames
_R_8:
bgezal	$9, _R_9
_not_R_9:
	j		_ames				# jump to _ames
_R_9:
bgezal	$10, _R_10
_not_R_10:
	j		_ames				# jump to _ames
_R_10:
bgezal	$11, _R_11
_not_R_11:
	j		_ames				# jump to _ames
_R_11:
bgezal	$12, _R_12
_not_R_12:
	j		_ames				# jump to _ames
_R_12:
bgezal	$13, _R_13
_not_R_13:
	j		_ames				# jump to _ames
_R_13:
bgezal	$14, _R_14
_not_R_14:
	j		_ames				# jump to _ames
_R_14:
bgezal	$15, _R_15
_not_R_15:
	j		_ames				# jump to _ames
_R_15:
bgezal	$16, _R_16
_not_R_16:
	j		_ames				# jump to _ames
_R_16:
bgezal	$17, _R_17
_not_R_17:
	j		_ames				# jump to _ames
_R_17:
bgezal	$18, _R_18
_not_R_18:
	j		_ames				# jump to _ames
_R_18:
bgezal	$19, _R_19
_not_R_19:
	j		_ames				# jump to _ames
_R_19:
bgezal	$20, _R_20
_not_R_20:
	j		_ames				# jump to _ames
_R_20:
bgezal	$21, _R_21
_not_R_21:
	j		_ames				# jump to _ames
_R_21:
bgezal	$22, _R_22
_not_R_22:
	j		_ames				# jump to _ames
_R_22:
bgezal	$23, _R_23
_not_R_23:
	j		_ames				# jump to _ames
_R_23:
bgezal	$24, _R_24
_not_R_24:
	j		_ames				# jump to _ames
_R_24:
bgezal	$25, _R_25
_not_R_25:
	j		_ames				# jump to _ames
_R_25:
bgezal	$26, _R_26
_not_R_26:
	j		_ames				# jump to _ames
_R_26:
bgezal	$27, _R_27
_not_R_27:
	j		_ames				# jump to _ames
_R_27:
bgezal	$28, _R_28
_not_R_28:
	j		_ames				# jump to _ames
_R_28:
bgezal	$29, _R_29
_not_R_29:
	j		_ames				# jump to _ames
_R_29:
bgezal	$30, _R_30
_not_R_30:
	j		_ames				# jump to _ames
_R_30:
bgezal	$31, _R_31
_not_R_31:
	j		_ames				# jump to _ames
_R_31:
	# if you are here you are good to go to ames (test passed)
	nop
	nop
	nop
	# bye~
_ames:


halt
