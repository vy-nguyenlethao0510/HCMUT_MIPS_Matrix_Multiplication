.data
	fileName: 	.space 21
	arr: 	.space 20000 
	
	name: 	.asciiz "Enter the file name: "
	behv: 	.asciiz ">> Press 0 to read selected file.\n>> Press 1 to write to selected file.\nYour choice is: "
	invalid: 	.asciiz "Invalid input!"
	print: 	.asciiz "\nThe array in file includes:\n"
	input: 	.asciiz "Enter number of elements in array: "
	prompt: 	.asciiz "Enter a number: "
	check: 	.asciiz "\nYou can check your file now to see the result!"
	
	comma: 	.asciiz ", "
	endl: 	.asciiz "\n"
.text
	# FILE NAME
	# ask user for input
	# call 'nameClean' to 
	# modify 'fileName'
	li 	$v0, 4
	la 	$a0, name
	syscall
	li 	$v0, 8
	la 	$a0, fileName
	li 	$a1, 21
	syscall
	
	jal 	nameClean
	
	# BEHAVIOR 
	# ask user for input
	# check input to
	# determine behavior
	li 	$v0, 4
	la 	$a0, behv
	syscall
	li 	$v0, 5
	syscall
	
	beq 	$v0, 0, read
	beq 	$v0, 1, write
	
	li 	$v0, 4
	la 	$a0, invalid
	syscall
	li 	$v0, 10
	syscall
	
	# call appropriate procedure
	read:
	jal 	readFile
	li 	$v0, 10
	syscall
	
	write:
	jal 	writeFile
	li 	$v0, 10
	syscall
	
	# READ FROM FILE
	readFile:	
		# save $ra to stack
		addi 	$sp, $sp, -4
		sw 	$ra, 0($sp)
		# open file
		li 	$v0, 13           
    		la 	$a0, fileName     	
    		li 	$a1, 0           	
    		syscall
    		move 	$s0, $v0
    		# read from opened file
    		li 	$v0, 14		
		move 	$a0, $s0	
		la 	$a1, arr  	
		la 	$a2, 100		
		syscall
		move 	$t0, $v0
		# close file
		li 	$v0, 16         		
    		move 	$a0,$s0      		
    		syscall
    		# print it to check
    		jal 	printarr
    		# take out $ra from stack
    		lw 	$ra, 0($sp)
    		addi 	$sp, $sp, 4
		jr 	$ra
	
	# Print array for checking
	printarr:
		li 	$t1, 0
		addi 	$t0, $t0, -2
		la 	$t2, arr
		
		li 	$v0, 4
		la 	$a0, print
		syscall
		
		loop: 
			beq 	$t1, $t0, done
			la 	$t2, arr
			addu 	$t2, $t2, $t1
			
			lbu 	$a0, 0($t2)
			beq 	$a0, 32, space
			
			li 	$v0, 11
			syscall
			addi 	$t1, $t1, 1
			j 	loop
			
			# if encounter space,
			# skip it and print 
			# a comma to separate
			# between elements
			space:
				li 	$v0, 4
				la 	$a0,comma
				syscall
				addi 	$t1, $t1, 1
				j 	loop
		done:
			jr 	$ra
	
	# WRITE TO FILE
	writeFile:
		# save $ra to stack
		addi 	$sp, $sp, -4
		sw 	$ra, 0($sp)
		# get the array to write
		# to file
    		li 	$v0, 4
    		la 	$a0, input
    		syscall
    		li 	$v0,5
    		syscall
    		addi 	$s0, $v0, 0           
    		addi 	$t9, $zero, 1                  	
	
		read4w:
			# open file
			li 	$v0, 13           
    			la 	$a0, fileName 
    			li 	$a1, 1           
    			syscall
    			move 	$s1, $v0  
			read_num:
    				bgt 	$t9, $s0, rdone        
		
    				li 	$v0, 4
    				la 	$a0, prompt
    				syscall
	
				li 	$v0,8
    				la 	$a0, arr            
    				li 	$a1, 20
    				syscall  
    		
    				la 	$t0, arr
    				jal 	strlen
    		
    			write2file:
    				li 	$v0, 15		
    				move 	$a0, $s1		
    				la 	$a1, arr		
    				la 	$a2, ($t3)		
    				syscall
    		
    			cont:	
				addi    	$t9, $t9, 1 
    				j       	read_num
		
		rdone:
			# close file
			li 	$v0, 16         		
    			move 	$a0, $s1      		
    			syscall
    			
    			li 	$v0, 4
    			la 	$a0, check
    			syscall
    			
			lw 	$ra, 0($sp)
    			addi 	$sp, $sp, 4
			jr 	$ra
	
	# HELPING PROCEDURES		
	
	# calculate length of string
	strlen: 
		lb   	$t1, 0($t0)
    		beq 	$t1, $zero, end

    		addi 	$t0, $t0, 1
    		j strlen

		end:
			la 	$t1, arr
			sub 	$t3, $t0, $t1
			jr 	$ra
	
	# the program adds 0x00 
	# and 0x0a at the end of 
	# user input in the memory
	# so we need to clean it
	nameClean:
    		li 	$t0, 0       #loop counter
    		li 	$t1, 21      #loop end
		clean:
    			beq 	$t0, $t1, cleaned
    			lb 	$t3, fileName($t0)
    			bne 	$t3, 0x0a, continue
    			sb 	$zero, fileName($t0)
    		continue:
    			addi 	$t0, $t0, 1
			j 	clean
		cleaned:
			jr 	$ra
			
			
			
			
