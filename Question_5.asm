.data
	fileA:	.asciiz "A.txt"
	fileB:	.asciiz "B.txt"
	fileR:	.asciiz "result.txt"

	rowA: 	.asciiz "Enter number of rows for matrix A: "
	colA: 	.asciiz "Enter number of columns for matrix A: " 
	rowB: 	.asciiz "Enter number of rows for matrix B: "
	colB: 	.asciiz "Enter number of columns for matrix B: " 

	matp: 	.asciiz "\nGenerated matrix: \n"
	result: 	.asciiz "\nResult of multiplication is: "
	retcode: 	.asciiz "\nReceived code: "
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
	move 	$s2, $s1
	move 	$s4, $t0
	move 	$s5, $t1
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
	bne 	$s5, $t0, dim_error
	# col A = row B, input col of B
	li 	$v0, 4
	la 	$a0, colB
	syscall
	li 	$v0, 5
	syscall
	move 	$t1, $v0
	# call allocation procedure for B
	addi 	$t5, $zero, 1
	jal 	mat_alloc
	move 	$s3, $s1
	move 	$s6, $t0
	move 	$s7, $t1
	# call allocation procedure for 
	# result matrix
	add 	$t0, $zero, $s4
	add 	$t1, $zero, $s7
	addi 	$t5, $zero, 2
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
		
	# INITIALIZATION
	init_value:
		li 	$t2, 0
		outer: 	# row loop 
			bge 	$t2, $t0, end_outer
			li 	$t3, 0
			
		inner:	# col loop
			bge 	$t3, $t1, end_inner
			mul 	$t4, $t2, $t1
			add 	$t4, $t4, $t3
			sll 	$t4, $t4, 2
			add 	$t4, $t4, $s1
			# if it is result matrix,
			# initialize every element as 0
			beq 	$t5, 2, init0
			# randomly generate integer
			li $v0, 42
			li $a1, 100
			syscall
			# store it to matrix
			sw 	$a0, 0($t4)
			
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
			beq 	$t5, 2, noprint
			jal 	print_mat
			noprint:
			lw 	$ra, 0($sp)
    			addi 	$sp, $sp, 4
			jr 	$ra
			
	print_mat:
		beq 	$t5, 2, res
		li 	$v0, 4
		la 	$a0, matp
		syscall
		
		# open file
		beq $t5, 0, openA
		beq $t5, 1, openB
		
		openA:
		li 	$v0, 13           
    		la 	$a0, fileA 
    		li 	$a1, 1           
    		syscall
    		move 	$s0, $v0
    		j begin
    		
    		openB:
    		li 	$v0, 13           
    		la 	$a0, fileB 
    		li 	$a1, 1           
    		syscall
    		move 	$s0, $v0
    		j begin
    		
    		res:
    		li 	$v0, 13           
    		la 	$a0, fileR 
    		li 	$a1, 1           
    		syscall
    		move 	$s0, $v0
    		
		begin:
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
			
			move $t4, $a0
			add $t6, $zero, $zero
			numOfDigit:
				addi $t6 $t6 1
				div $a0 $a0 10
				beq $a0 0 convert
				j numOfDigit
			
			convert:
				addi $t7, $t6, 1
				li $v0, 9
				la $a0, ($t7)
				syscall
				move $t7, $v0
				# point to the end 
				add $t7, $t7, $t6
				
				convloop:	# store digits backward
					div $t4, $t4, 10
					mfhi $t8
					addi $t8, $t8, 48
					sb $t8, 0($t7)
					addi $t7, $t7, -1
					bne $t4, 0, convloop
					addi $t7, $t7, 1
				write:
					li $v0, 15       
					move $a0, $s0      
					move $a1, $t7      
					la $a2, ($t6)       
					syscall            	
			
					li $v0, 15       
					move $a0, $s0      
					la $a1, blank       
					li $a2, 1       
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
			
			li $v0, 15       
			move $a0, $s0      
			la $a1, endl       
			li $a2, 1       
			syscall 
			
			j 	outer_p
			
		end_outer_p:
			# close file
			li 	$v0, 16         		
    			move 	$a0, $s0      		
    			syscall
    				
			jr 	$ra
	
	# MULTIPLICATION
	# Registers using at this time:
	# Matrix A: base addr = $s2, heightA = $s4, widthA = $s5
	# Matrix B: base addr = $s3, heightB = $s6, widthB = $s7
	# Matrix result: base addr = $s1		
	mat_mul: 
		addi 	$sp, $sp, -4
		sw 	$ra, 0($sp)
		li $t0, 0
		
		loop_t0_i:
			beq 	$t0, $s4, endloopi
			li 	$t1, 0
			
			loop_t1_j:
				beq 	$t1, $s7, endloopj
				li 	$t2, 0
				
				loop_t2_k:
					beq 	$t2, $s5, endloopk
					# t3 = A[i][k] 
					# addr = base address + (4 * (widthA * k + i))
					mul 	$t3, $t0, $s5
					add 	$t3, $t3, $t2
					sll 	$t3, $t3, 2
					add 	$t3, $t3, $s2
					lw 	$t3, 0($t3) 
					# t4 = B[k][j]
					# addr = base address + (4 * (widthB * j + k))
					mul 	$t4, $t2, $s7
					add 	$t4, $t4, $t1
					sll 	$t4, $t4, 2
					add 	$t4, $t4, $s3
					lw 	$t4, 0($t4)
					# $t5 = addr of result[i][j]
					# addr = base address + (4 * (widthB * j + i))
					mul 	$t5, $t0, $s7
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
			
			add 	$t0, $zero, $s4
			add 	$t1, $zero, $s7
			add 	$t5, $zero, 2
			jal 	print_mat
			
			lw 	$ra, 0($sp)
    			addi 	$sp, $sp, 4
			jr 	$ra
				    
					     
					      
					       
					        
					         
					          
					            
