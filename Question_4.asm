.data
	input: 	.asciiz ">> Enter data of matrix: \n"
	rowA: 	.asciiz "Enter number of rows for matrix A: "
	colA: 	.asciiz "Enter number of columns for matrix A: " 
	rowB: 	.asciiz "Enter number of rows for matrix B: "
	colB: 	.asciiz "Enter number of columns for matrix B: " 
	
	row_maj: 	.asciiz "> Input data for matrix at row "
	num: 	.asciiz "Enter a number: "
	matp: 	.asciiz "\nInserted matrix: \n"
	result: 	.asciiz "\nResult of multiplication is: "
	retcode: 	.asciiz "Received code: "
	dime: 	.asciiz "\nDimension error!"
	
	endl: 	.asciiz "\n"
	blank: 	.asciiz " "
.text
	# DIMENSIONS
	
	# $t5 is used to indicate
	# input or output matrix
	addi 	$t5, $zero, 0	
	
	# input row of A
	li 	$v0, 4
	la 	$a0, rowA
	syscall
	li 	$v0, 5
	syscall
	move 	$t0, $v0
	# input col of A
	li 	$v0, 4
	la 	$a0, colA
	syscall
	li 	$v0, 5
	syscall
	move 	$t1, $v0
	# call allocation procedure for A	
	jal 	mat_alloc
	move 	$s3, $s1
	move 	$t6, $t0
	move 	$t7, $t1
	# input row of B	
	li 	$v0, 4
	la 	$a0, rowB
	syscall
	li 	$v0, 5
	syscall
	move 	$t0, $v0
	# check multiplication condition
	# col A = row B, it not satisfied,
	# print error msg and terminate
	bne 	$t7, $t0, dim_error
	# col A = row B, input col of B
	li 	$v0, 4
	la 	$a0, colB
	syscall
	li 	$v0, 5
	syscall
	move 	$t1, $v0
	# call allocation procedure for B
	jal 	mat_alloc
	move 	$s4, $s1
	move 	$t8, $t0
	move 	$t9, $t1
	# call allocation procedure for 
	# result matrix
	add 	$t0, $zero, $t6
	add 	$t1, $zero, $t9
	addi 	$t5, $zero, 1
	jal 	mat_alloc
	
	# call multiplication procedure
	jal 	mat_mul
		
	# RESULT
	li 	$v0, 4
	la 	$a0, retcode
	syscall
	li 	$v0, 1
	addi 	$a0, $zero, 0	
	syscall		
					
	li 	$v0,10
	syscall
	
	# handle dimension error
	dim_error:
		li 	$v0, 4
		la 	$a0, retcode
		syscall
		li 	$v0, 1
		addi 	$a0, $zero, -1
		syscall
		
		li 	$v0, 4
		la 	$a0, dime
		syscall
	
		li 	$v0, 10
		syscall
	
	# ALLOCATION
	mat_alloc:
		# save $ra onto stack
		addi 	$sp, $sp, -4
		sw 	$ra, 0($sp)
		# alloc memory
		mul 	$a0, $t0, $t1
		sll 	$a0, $a0, 3
		li 	$v0, 9
		syscall
		move 	$s1, $v0
		
		# if $t5 = 1, then we are
		# dealing with result matrix
		beq 	$t5, 1, init_value
		
		li 	$v0, 4
		la 	$a0, input
		syscall
		
	# INITIALIZATION
	init_value:
		li 	$t2, 0
		outer: 	# row loop 
			bge 	$t2, $t0, end_outer
			beq 	$t5, 1, noprompt
			li 	$v0, 4
			la 	$a0, row_maj
			syscall
			li 	$v0, 1
			la 	$a0, ($t2)
			syscall
			li 	$v0, 4
			la 	$a0, endl
			syscall
			
			noprompt:
			li 	$t3, 0
			
		inner:	# col loop
			bge 	$t3, $t1, end_inner
			mul 	$t4, $t2, $t1
			add 	$t4, $t4, $t3
			sll 	$t4, $t4, 2
			add 	$t4, $t4, $s1
			# if it is result matrix,
			# initialize every element as 0
			beq 	$t5, 1, init0
			
			li 	$v0, 4
			la 	$a0, num
			syscall
			li 	$v0, 5
			syscall
			sw 	$v0, 0($t4)
			addiu 	$t3, $t3, 1
			j 	inner
			
			init0:
			addi 	$v0, $zero, 0
			sw 	$v0, 0($t4)
			addiu 	$t3, $t3, 1
			j 	inner
				
		end_inner:
			addiu 	$t2, $t2, 1
			j 	outer
			
		end_outer:
			beq 	$t5, 1, noprint
			jal 	print_mat
			noprint:
			lw 	$ra, 0($sp)
    			addi 	$sp, $sp, 4
			jr 	$ra
			
	print_mat:
		beq 	$t5, 1, res
		li 	$v0, 4
		la 	$a0, matp
		syscall
		res:
		li 	$t2, 0
		outer_p: 	# row loop
			bge 	$t2, $t0, end_outer_p
			li 	$t3, 0
			
		inner_p:	# col loop
			bge 	$t3, $t1, end_inner_p
			mul 	$t4, $t2, $t1
			add 	$t4, $t4, $t3
			sll 	$t4, $t4, 2
			add 	$t4, $t4, $s1
			
			lw 	$a0, 0($t4)
			li 	$v0, 1
			syscall
			li 	$v0, 4
			la 	$a0, blank
			syscall
			addiu 	$t3, $t3, 1
			
			j 	inner_p
			
		end_inner_p:
			addiu 	$t2, $t2, 1
			li 	$v0, 4
			la 	$a0, endl
			syscall
			j 	outer_p
			
		end_outer_p:	
			jr 	$ra
	
	# MULTIPLICATION
	# Registers using at this time:
	# Matrix A: base addr = $s3, heightA = $t6, widthA = $t7
	# Matrix B: base addr = $s4, heightB = $t8, widthB = $t9
	# Matrix result: base addr = $s1		
	mat_mul: 
		addi 	$sp, $sp, -4
		sw 	$ra, 0($sp)
		li $t0, 0
		
		loop_t0_i:
			beq 	$t0, $t6, endloopi
			li 	$t1, 0
			
			loop_t1_j:
				beq 	$t1, $t9, endloopj
				li 	$t2, 0
				
				loop_t2_k:
					beq 	$t2, $t7, endloopk
					# t3 = A[i][k] 
					# addr = base address + (4 * (widthA * k + i))
					mul 	$t3, $t0, $t7
					add 	$t3, $t3, $t2
					sll 	$t3, $t3, 2
					add 	$t3, $t3, $s3
					lw 	$t3, 0($t3) 
					# t4 = B[k][j]
					# addr = base address + (4 * (widthB * j + k))
					mul 	$t4, $t2, $t9
					add 	$t4, $t4, $t1
					sll 	$t4, $t4, 2
					add 	$t4, $t4, $s4
					lw 	$t4, 0($t4)
					# $t5 = addr of result[i][j]
					# addr = base address + (4 * (widthB * j + i))
					mul 	$t5, $t0, $t9
					add 	$t5, $t5, $t1
					sll 	$t5, $t5, 2
					add 	$t5, $t5, $s1
					# result[i][j] 
					# += A[i][k] * B[k][j]
					mul 	$t3, $t3, $t4
					lw 	$t4, 0($t5)
					add 	$t3, $t3, $t4
					sw 	$t3, 0($t5)
					
					addiu 	$t2, $t2, 1
					j 	loop_t2_k 
					
				endloopk:
					addiu 	$t1, $t1, 1
					j 	loop_t1_j
					
			endloopj:
				addiu 	$t0, $t0, 1
				j 	loop_t0_i
				
		endloopi:
			# print out result matrix
			li 	$v0, 4
			la 	$a0, result
			syscall
			li 	$v0, 4
			la 	$a0, endl
			syscall
			
			add 	$t0, $zero, $t6
			add 	$t1, $zero, $t9
			add 	$t5, $zero, 1
			jal 	print_mat
			
			lw 	$ra, 0($sp)
    			addi 	$sp, $sp, 4
			jr 	$ra
				    
					     
					      
					       
					        
					         
					          
					            
