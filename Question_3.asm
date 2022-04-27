.data
	num: 	.asciiz "\nEnter a number: "
	nume: 	.asciiz "Number of elements of the array: "
	size: 	.asciiz "Size of each element (in bytes): "
	err: 	.asciiz "\nReceived error code: -1\nYou requested more than 65536 bytes!"
	suc: 	.asciiz "\nReceived success code: 0"
	addr: 	.asciiz "\nThe first address of allocated array: "
	veri: 	.asciiz "\n>> You can input some integers to check if it works.\nPress 0 to skip this part. Press 1 to continue: "
	print: 	.asciiz "\nYour array includes: "
	
	endl: 	.asciiz "\n"
	spc: 	.asciiz " "
.text
	# NUMER OF ELEMENTS 
	# ask user to input
	# number of elements
	li 	$v0, 4
	la 	$a0, nume
	syscall
	li 	$v0, 5
	syscall		
	move 	$t9, $v0		
	
	# SIZE OF EACH 
	# ask user to input
	# size of element
	li 	$v0, 4
	la 	$a0, size
	syscall
	li 	$v0, 5
	syscall
	move 	$t8, $v0		 
	
	# call procedure
	jal 	allocation
	
	# t1 = return code
	# if return code == -1, 
	# branch to alloc_fail 
	# and print error code
	move 	$t1, $v1		
	beq 	$t1, -1, alloc_fail	
				
	# PRINT SUCCESS RESULT 
	move 	$t2, $v0
	li 	$v0, 4
	la 	$a0, suc
	syscall
	li 	$v0, 4
	la 	$a0, addr
	syscall
	li 	$v0, 34
	la 	$a0, 0($t2)
	syscall
	li 	$v0, 4
	la 	$a0, endl
	syscall
	
	# FOR TESTING ONLY
	# after allocation,
	# ask user for some inputs
	# for verification
	testing:
		addi 	$t0, $zero, 0
		li 	$v0, 4
		la 	$a0, veri
		syscall
		li $v0, 5
		syscall
		beq $v0, 0, end
		beq $v0, 1, loop
		
		li $v0, 10
		syscall 
	
	loop:
		beq 	$t0, $t9, printarr
		li 	$v0, 4
		la 	$a0, num
		syscall
		li 	$v0, 5
		syscall
	
		mul 	$t4, $t0, $t8	
		add 	$t4, $t2, $t4
		sw 	$v0, 0($t4)
		addi 	$t0, $t0, 1 
		j 	loop
	
	printarr:
		addi 	$t0, $zero, 0
		li 	$v0, 4
		la 	$a0, print
		syscall
		
		printloop:
			beq 	$t0, $t9, end
			mul 	$t4, $t0, $t8 	
			add 	$t4, $t2, $t4
			li 	$v0, 1
			lw 	$a0, 0($t4)
			syscall
			li 	$v0, 4
			la 	$a0, spc
			syscall
			addi	$t0, $t0, 1 
			j 	printloop

	end:	
		li 	$v0, 10
		syscall
	
	# ALLOCATION
	allocation:
		# calculate number of bytes needed
		mul 	$t0, $t9, $t8
		# if > 65536, branch to 'error'		
		bgt 	$t0, 65536, error
		# if not, allocate memory	
		li 	$v0, 9			
		la 	$a0, 0($t0)
		syscall
		# return code and go back
		addi 	$v1, $zero, 0		
		jr 	$ra
	
	error:
		addi 	$v1, $zero, -1		
		jr 	$ra
	
	alloc_fail:
		li 	$v0, 4
		la 	$a0, err
		syscall
	
		li 	$v0, 10
		syscall
	
	
	
	
	
	
