.equ HEAD_X, 0x1000 ; snake head's position on x-axis
.equ HEAD_Y, 0x1004 ; snake head's position on y-axis
.equ TAIL_X, 0x1008 ; snake tail's position on x-axis
.equ TAIL_Y, 0x100C ; snake tail's position on y-axis
.equ SCORE, 0x1010 ; score address
.equ GSA, 0x1014 ; game state array
.equ LEDS, 0x2000 ; LED addresses
.equ SEVEN_SEGS, 0x1198 ; 7-segment display addresses
.equ RANDOM_NUM, 0x2010 ; Random number generator address
.equ BUTTONS, 0x2030 ; Button addresses


	addi sp, zero,LEDS
	
restart_loop:
	call wait
	call restart_game	
	addi t0, zero, 1
	beq t0, v0, pre_main
	br restart_loop

pre_main:
	call draw_array
	call wait

main_loop:
	call clear_leds
	call get_input
	call hit_test
	
	addi t0, zero, 2		; Initializing t0 
	beq v0, t0, terminate_game
	addi t0, zero, 1
	beq v0, t0, food_hit

no_changes:
	call move_snake
	call draw_array
	call wait
	call restart_game	
	addi t0, zero, 1
	beq t0, v0, pre_main
	br main_loop

food_hit:
	addi a0, zero, 1 ; That means we have eaten some food, this argument is needed in move_snake
	ldw t0, SCORE(zero)		; we load the current score in t0
	addi t0, t0, 1			; score is incremented
	stw t0, SCORE(zero)		; score is stored after update
	call display_score
	call create_food
	br no_changes

terminate_game: 
	call draw_array
	br restart_loop
	 
ret


wait:
	addi t0, zero, 1		; Initialing the counter 
	slli t0, t0, 22
	;srli t0, t0, 1			

wait_loop:
	beq t0, zero, stop	
	addi t0, t0, -1
	br wait_loop

stop: ret
ret 

; BEGIN:clear_leds
clear_leds:
stw zero, LEDS(zero)		; Storing the results in LEDS[0]
stw zero, LEDS+4(zero)	; Storing the results in LEDS[1]
stw zero, LEDS+8(zero)	; Storing the results in LEDS[2]

ret
; END:clear_leds

; BEGIN:set_pixel
set_pixel:

addi s1, zero, 1
addi s2, zero, 2
addi s3, zero, 3

cmplti t7, a0, 4		; Compares the x value is less than 4
bne zero, t7, led0		; if it is true that means we're in LED[0]
cmplti t7, a0, 8		; otherwise we could be in LED[1] or LED[2]
bne zero, t7, led1		; Compares the x value is less than 8
cmplti t7, a0, 12		; otherwise we could be in LED[2]
bne zero, t7, led2

led0:

ldw s4, LEDS(zero)		; Upload the current state of the LEDS[0]

beq a0, zero, led0_0	; Compares: x=0
beq a0, s1, led0_1		; Compares: x=1
beq a0, s2, led0_2		; Compares: x=2
beq a0, s3, led0_3		; Compares: x=3

ret

led0_0:					; We enter here if we want to modify bits[7:0]
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS(zero)
ret

led0_1:					; We enter here if we want to modify bits[15:8]
addi a1, a1, 8			; We add 8 in order to select the second group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS(zero)
ret

led0_2:					; We enter here if we want to modify bits[23:16]
addi a1, a1, 16			; We add 8 in order to select the third group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1
stw s4, LEDS(zero)
ret

led0_3:					; We enter here if we want to modify bits[31:24]
addi a1, a1, 24			; We add 8 in order to select the fourth group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS(zero)
ret



led1:

ldw s4, LEDS+4(zero)	; Upload the current state of the LEDS[1]

sub a0, a0, s1
sub a0, a0, s3			; Substract a0-4 to have a value 0<x<4

beq a0, zero, led1_0	; Compares: x=0
beq a0, s1, led1_1		; Compares: x=1
beq a0, s2, led1_2		; Compares: x=2
beq a0, s3, led1_3		; Compares: x=3

ret


led1_0:					; We enter here if we want to modify bits[7:0]
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+4(zero)
ret

led1_1:					; We enter here if we want to modify bits[15:8]
addi a1, a1, 8			; We add 8 in order to select the second group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+4(zero)
ret

led1_2:					; We enter here if we want to modify bits[23:16]
addi a1, a1, 16			; We add 8 in order to select the third group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1
stw s4, LEDS+4(zero)
ret

led1_3:					; We enter here if we want to modify bits[31:24]
addi a1, a1, 24			; We add 8 in order to select the fourth group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+4(zero)
ret



led2:
ldw s4, LEDS+8(zero)

sub a0, a0, s2
sub a0, a0, s3
sub a0, a0, s3			; Substract a0-8 to have a value 0<x<4

beq a0, zero, led2_0	; Compares: x=0
beq a0, s1, led2_1		; Compares: x=1
beq a0, s2, led2_2		; Compares: x=2
beq a0, s3, led2_3		; Compares: x=3

ret 

led2_0:					; We enter here if we want to modify bits[7:0]
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+8(zero)
ret

led2_1:					; We enter here if we want to modify bits[15:8]
addi a1, a1, 8			; We add 8 in order to select the second group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+8(zero)
ret

led2_2:					; We enter here if we want to modify bits[23:16]
addi a1, a1, 16			; We add 8 in order to select the third group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1
stw s4, LEDS+8(zero)
ret

led2_3:					; We enter here if we want to modify bits[31:24]
addi a1, a1, 24			; We add 8 in order to select the fourth group of bits
sll s1, s1, a1			; Shift left "y" times
or s4, s4, s1 
stw s4, LEDS+8(zero)
ret

; END:set_pixel

; BEGIN:get_input
get_input:

	ldw t0, BUTTONS(zero) 	; t0 has status
	ldw t1, BUTTONS+4(zero)	; t1 has edgecapture

	addi t5, zero, 31
	beq t1, zero, exit_getInp	; if no button is pressed, stop the function 


; if status isn't only ones, it means a button has been pressed, we will then put edgacture as the head's new GSA

	ldw t2, HEAD_X(zero)	; t2 has x cood
	ldw t3, HEAD_Y(zero)	; t3 has y cood

	slli t2, t2, 5			; x32
	slli t3, t3, 2			; x4
	add t4, t2, t3			; 32*X + 4*Y
	addi t4, t4, GSA		; Final head GSA address
	ldw t7, 0(t4)			; t7 holds the content of the head's GSA

	andi t1, t1, 15			; ignore bit 5, t1 has edgecapture without the reset info

; now we try to see which button was pressed
	
	addi t6, zero, 0		; will serve as counter
	addi t6, zero, 1		; t6 = 1 
	beq t1, t6, GSALeft		; put 1 into the GSA
	
	addi t6, zero, 2
	beq t1, t6, GSAUp		; put 2 into the GSA

	addi t6, zero, 4		
	beq t1, t6, GSADown		; put 3 into the GSA

	addi t6, zero, 8
	beq t1, t6, GSARight 	; put 4 into the GSA


GSALeft:
	addi t6, zero, 1		; the new GSA
	addi t2, zero, 4		; the value associated with going rightwards
	beq t7, t2, exit_getInp	; if we were currently going right, we can't go left
	stw t6, 0(t4)
	br clear

GSAUp:
	addi t6, zero, 2		; the new GSA
	addi t2, zero, 3		; the value associated with going downwards
	beq t7, t2, exit_getInp	; if we were currently going down, we can't go up
	stw t6, 0(t4)
	br clear

GSADown:
	addi t6, zero, 3		; the new GSA
	addi t2, zero, 2		; the value associated with going upwards
	beq t7, t2, exit_getInp	; if we were currently going right, we can't go left
	stw t6, 0(t4)
	br clear

GSARight:
	addi t6, zero, 4		; the new GSA
	addi t2, zero, 1		; the value associated with going leftwards
	beq t7, t2, exit_getInp	; if we were currently going right, we can't go left
	stw t6, 0(t4)
	br clear

clear:
	stw zero, BUTTONS+4(zero)	; clear edgecapture
ret


exit_getInp:
	stw zero, BUTTONS+4(zero)	; clear edgecapture
ret
; END:get_input

; BEGIN:move_snake
move_snake:
	
	;----------------- HEAD Handling ---------------------

	ldw t0, HEAD_X(zero)	; loading x cood of head
	ldw t1, HEAD_Y(zero)	; loading y cood of head
	
							; retreive GSA of head
	
	slli t2, t0, 5			; 32X
	slli t3, t1, 2			; 4Y

	add t4, t2, t3			; store 32X + 4Y
	addi t5, t4, GSA		; t5 contains the GSA address of the head

	ldw	t6, 0(t5)			; load in t6 the content of the head's GSA

	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call

	call updateX			; updateX
	call updateY			; updateY

	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer

	; At this moment, t0 and t1 contain the new values for x and y respectively and t6 still holds the old GSA's content

	stw t0, HEAD_X(zero)	; put the new X value in HEAD_X
	stw t1, HEAD_Y(zero)	; put the new Y value in HEAD_Y

	; Now we calculate the new head's GSA address
 
	slli t2, t0, 5			; 32X
	slli t3, t1, 2			; 4Y

	add t4, t2, t3			; store 32X + 4Y
	addi t5, t4, GSA		; t5 contains the GSA address of the new head
	
	stw t6, 0(t5)			; store  the old GSA content(t6) in the new GSA address(t5)



	;----------------- TAIL Handling ---------------------


	addi t2, zero, 1		; we store in t2 the value 1
	beq a0, t2, endMoveSnake; if a0 = 1 then we directly return

	ldw t0, TAIL_X(zero)	; loading x cood of tail
	ldw t1, TAIL_Y(zero)	; loading y cood of tail

							; retreive GSA of tail
	
	slli t2, t0, 5			; 32X
	slli t3, t1, 2			; 4Y

	add t4, t2, t3			; store 32X + 4Y
	addi t5, t4, GSA		; t5 contains the GSA address of the tail

	ldw	t6, 0(t5)			; load in t6 the content of the tail's GSA

	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call
	
	call updateX			; updateX
	call updateY			; updateY

	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer

	; At this moment, t0 and t1 contain the new values for x and y respectively and t6 still holds the old GSA's content
	; and t5 still holds the ol GSA
	
	stw t0, TAIL_X(zero)	; put the new X value in HEAD_X
	stw t1, TAIL_Y(zero)	; put the new Y value in HEAD_Y

	; Now we calculate the new tail's GSA address
 
	slli t2, t0, 5			; 32X
	slli t3, t1, 2			; 4Y

	add t4, t2, t3			; store 32X + 4Y
	addi t7, t4, GSA		; t7 contains the GSA address of the new tail
	
	stw zero, 0(t5)			; store 0 ath the old GSA address t5 (i.e turn it off)

endMoveSnake: ret



	;---------------- Auxilliary functions ---------------------


updateX:

	addi t2, zero, 1		; stock in t2 the value 1
	beq t6, t2, decX		; if head's GSA is 1, decrement X
	addi t2, zero, 4		; stock in t2 the value 4
	beq t6, t2, incX		; if head's GSA is 4, increment X
ret

decX:
	addi t0, t0, -1			; decrement X value in t0 by 1
ret

incX:
	addi t0, t0, 1			; increment X value in t0 by 1
ret


updateY:

	addi t2, zero, 2		; stock in t2 the value 2
	beq t6, t2, decY		; if head's GSA is 2, decrement Y
	addi t2, zero, 3		; stock in t2 the value 3
	beq t6, t2, incY		; if head's GSA is 3, increment Y
ret	

decY:
	addi t1, t1, -1			; decrement Y value in t1 by 1
ret

incY:
	addi t1, t1, 1			; increment Y value in t1 by 1
ret


; END:move_snake

; BEGIN:draw_array
draw_array:

	;--------------------- Main loop ------------------------

	addi t0, zero, GSA		; initialize t0 as a counter to iterate through all GSAs
	addi t1, zero, SEVEN_SEGS ; put in t1 the stop address 
	
; SEVEN_SEGS is the value at which we want to stop iterating through the GSAs, iterating is done by steps of size 4

loop:
	
	
	beq t0, t1, end_draw_array

	ldw t2, 0(t0)			; load in t2 the currently examined GSA

	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested ca	

	call draw				; call draw, which will compare and eventually set a pixel 
	
	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer
	

	addi t0, t0, 4			; increment t0, i.e progress through the GSAs
	br loop					; keep looping

end_draw_array:
	addi a0, zero, 0
	addi a1, zero, 0
ret	


	;---------------- Auxilliary functions ---------------------

draw:
	
	beq t2, zero, endDraw	; if pixel should be turned off, terminate
	
	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call
	
	call cood

	add a0, zero, t3		; put in a0 the newly found xCood in preparation of set pixel
	add a1, zero, t4		; put in a0 the newly found xCood in preparation of set pixel	
	
	call set_pixel

	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer
	
endDraw: ret

; function cood finds the values of x and y from the GSA address (in t0)
cood:

	addi t3, zero, 0		; t3 will contain x coordinate, initialize to 0
	addi t4, zero, 0		; t4 will contain y coordinate, initialize to 0
	addi t5, t0, 0			; t5 will contain the GSA address that we'll modify to find out x and y, preserving t0 
	addi t6, zero, GSA		; t6 will be used to compare value to GSA (because it's not a register)

; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call

	call Xloop
	call Yloop

; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer

ret


Xloop:
	
	blt t5, t6, adj_exitX	; if we've passed the GSA value, we have our xCood
	addi t5, t5, -32		; decrement GSA by a step (size 32)
	addi t3, t3, 1			; increment xCood
	br Xloop				; keep looping	

adj_exitX:

	addi t3, t3, -1			; adjust xCood
	addi t5, t5, 32			; adjust t5 for incoming Yloop
	br endXloop				; terminate
	

endXloop: ret

Yloop:
	
	blt t5, t6, adj_exitY	; if we've passed the GSA value, we have our xCood
	addi t5, t5, -4			; decrement GSA by a step (size 4)
	addi t4, t4, 1			; increment yCood
	br Yloop				; keep looping	

adj_exitY:

	addi t4, t4, -1			; adjust yCood
	br endYloop				; terminate
	
endYloop: ret
; END:draw_array


; BEGIN:create_food
create_food:
	
	addi t0, zero, 1
;	stw t0, RANDOM_NUM(zero); we write at RANDOM_NUM to generate a number
	ldw	t0, RANDOM_NUM(zero); the newly generated number is loaded in t0

	andi t0, t0, 255		; uses a mask to keep only the lsb of the random number
	
; we verify that the number is postive and < 96

	addi t1, zero, 96
	blt t0, zero, create_food
	bge t0, t1, create_food

; up to here, our random number is valid, we'll check the GSA of the corresponding pixel to see if it is free

	slli t0, t0, 2			; we adjust our number by factor x4 to then sum to GSA address start (hexa format)
	ldw t1, GSA(t0)			; t1 now contains the GSA of our pixel

	bne t1, zero, create_food; if the GSA is different from 0, it's not possible to put food there
	
	addi t1, zero, 5		; put value 5 (food) into t1
	stw t1, GSA(t0)			; the new GSA becomes 5 for the corrresponding pixel
	

ret
; END:create_food

; BEGIN:hit_test
hit_test:

; first we load the head coordinates, then we'll compute its GSA address

	ldw t0, HEAD_X(zero)	; x cood
	ldw t1, HEAD_Y(zero)	; y cood

	slli t0, t0, 5			; 32X
	slli t1, t1, 2			; 4Y

	add t2, t0, t1			; store 32X + 4Y
	addi t3, t2, GSA		; t2 contains the GSA address of the head

	ldw t4, 0(t3)			; load the head's GSA
	
; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call
	
	call Hupdate

; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer


; t0 and t1 now contain the "coordinates" (format x4) of the block the snake is about to hit, let's retreive it's GSA

	blt t0, zero, boundHit	; CASE: left boundary was hit (X cood < 0)

	addi t5, zero, 11		; max X value in normal format
	slli t5, t5, 5			; x32
	addi t5, t5, 1			; minimum invalid value (command > doesn't exist)
	bge t0, t5, boundHit	; CASE: right bound was hit (X cood > 11)

	blt t1, zero, boundHit	; CASE: upper bound was hit (Y cood < 0)

	addi t5, zero, 7		; max Y value in normal format
	slli t5, t5, 2			; x4
	addi t5, t5, 1			; minimum invalid value (command > doesn't exist)
	bge t1, t5, boundHit	; CASE: lower bound was hit (Y cood > 7)


	add t2, t0, t1			; store "32X + 4Y"
	addi t3, t2, GSA		; t3 now contains the GSA address of the next block

	ldw t4, 0(t3)			; load the next block's GSA


	addi t5, zero, 5		; load in t5 the value 5
	beq t4, t5, foodHit		; CASE: food was hit (GSA = 5)
	bne t4, zero, snakeHit	; CASE: snake was hit (0 < GSA < 5)
	

; if the program reaches this point it means the next block was neither food, snake or boundary, we return 0
	addi v0, zero, 0
ret



; ----------------------- Auxiliary functions ---------------------------

Hupdate:
	br HupdateX

HupdateX:

	addi t5, zero, 1		; stock in t5 the value 1
	beq t4, t5, HdecX		; if head's GSA is 1, decrement X
	addi t5, zero, 4		; stock in t5 the value 4
	beq t4, t5, HincX		; if head's GSA is 4, increment X
	br HupdateY

HdecX:
	addi t0, t0, -32		; decrement X value in t0 by 32 (x is in x4 format)
	br HupdateY

HincX:
	addi t0, t0, 32			; increment X value in t0 by 32 (x is in x4 format)
	br HupdateY


HupdateY:

	addi t5, zero, 2		; stock in t5 the value 2
	beq t4, t5, HdecY		; if head's GSA is 2, decrement Y
	addi t5, zero, 3		; stock in t5 the value 3
	beq t4, t5, HincY		; if head's GSA is 3, increment Y
ret	

HdecY:
	addi t1, t1, -4			; decrement Y value in t1 by 1
ret

HincY:
	addi t1, t1, 4			; increment Y value in t1 by 1
ret


foodHit:
	addi v0, zero, 1		; store 1 in v0
ret

snakeHit:
	addi v0, zero, 2		; store 2 in v0
ret

boundHit:
	addi v0, zero, 2		; store 2 in v0
ret
; END:hit_test


; BEGIN:display_score
display_score:

	addi t1, zero, 252		; load display value for 0 in t1
	stw t1, SEVEN_SEGS(zero); put into the first display slot
	stw t1, SEVEN_SEGS+4(zero)	; put into the second display slot
	stw t1, SEVEN_SEGS+8(zero)	; put into the third display slot
	stw t1, SEVEN_SEGS+12(zero)	; put into the fourth display slot
	

; we now need to determine the 2 digits of the score

	ldw t0, SCORE(zero)
	addi t3, zero, 0		; t3 will contain the futur decimal number
	addi t4, zero, 0		; t4 will contain the futur unit number
	addi t5, t0, 0 			; t5 will contain the updated score that we'll modify to find out t3 and t4, preserving t0
	
	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call

	call DEC_loop			; t3 now contains the proper decimal number
	call UNI_loop			; t4 now contains the proper unit number

	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer

	
; we now need to link the values of the decimal and unit to corresponding display words

; first the decimal
	
	addi t5, zero, 0		; will serve as counter
	beq t5, t3, disp0_DEC	; if =0, display 0
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp1_DEC		; if =1, display 1
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp2_DEC		; if =2, display 2
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp3_DEC		; if =3, display 3
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp4_DEC		; if =4, display 4
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp5_DEC		; if =5, display 5
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp6_DEC		; if =6, display 6
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp7_DEC		; if =7, display 7
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp8_DEC		; if =8, display 8
	addi t5, t5, 1			; increment counter
	beq t5, t3, disp9_DEC		; if =9, display 9


disp0_DEC:	
	addi t1, zero, 252		; load display value for 0 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp1_DEC:	
	addi t1, zero, 96		; load display value for 1 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp2_DEC:	
	addi t1, zero, 218		; load display value for 2 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp3_DEC:	
	addi t1, zero, 242 		; load display value for 3 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp4_DEC:	
	addi t1, zero, 102		; load display value for 4 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp5_DEC:	
	addi t1, zero, 182		; load display value for 5 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp6_DEC:	
	addi t1, zero, 190		; load display value for 6 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp7_DEC:	
	addi t1, zero, 224		; load display value for 7 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp8_DEC:	
	addi t1, zero, 254		; load display value for 8 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI

disp9_DEC:	
	addi t1, zero, 246		; load display value for 9 in t1
	stw t1, SEVEN_SEGS+8(zero) ; put into the third display slot
br UNI_display				; handle the UNI


; then the unit

UNI_display:
	
	addi t5, zero, 0		; will serve as counter
	beq t5, t4, disp0_UNI	; if =0, display 0
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp1_UNI		; if =1, display 1
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp2_UNI		; if =2, display 2
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp3_UNI		; if =3, display 3
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp4_UNI		; if =4, display 4
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp5_UNI		; if =5, display 5
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp6_UNI		; if =6, display 6
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp7_UNI		; if =7, display 7
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp8_UNI		; if =8, display 8
	addi t5, t5, 1			; increment counter
	beq t5, t4, disp9_UNI		; if =9, display 9
	
	
disp0_UNI:	
	addi t1, zero, 252		; load display value for 0 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp1_UNI:	
	addi t1, zero, 96		; load display value for 1 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp2_UNI:	
	addi t1, zero, 218		; load display value for 2 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp3_UNI:	
	addi t1, zero, 242		; load display value for 3 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp4_UNI:	
	addi t1, zero, 102		; load display value for 4 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp5_UNI:	
	addi t1, zero, 182		; load display value for 5 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp6_UNI:	
	addi t1, zero, 190		; load display value for 6 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp7_UNI:	
	addi t1, zero, 224		; load display value for 7 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp8_UNI:	
	addi t1, zero, 254		; load display value for 8 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

disp9_UNI:	
	addi t1, zero, 246		; load display value for 9 in t1
	stw t1, SEVEN_SEGS+12(zero) ; put into the third display slot
ret

ret

; ------------------ Auxiliary functions -----------------------


DEC_loop:
	
	blt t5, zero, adj_exit_DEC	; if we've passed 0, we have our decimal number
	addi t5, t5, -10		; decrement score by a step (size 10)
	addi t3, t3, 1			; increment DEC
	br DEC_loop				; keep looping	

adj_exit_DEC:

	addi t3, t3, -1			; adjust DEC
	addi t5, t5, 10			; adjust t5 for incoming UNI_loop
	br endDECloop			; terminate
	

endDECloop: ret


UNI_loop:
	
	blt t5, zero, adj_exit_UNI	; if we've passed 0, we have our unit number
	addi t5, t5, -1			; decrement score by a step (size 1)
	addi t4, t4, 1			; increment UNI
	br UNI_loop				; keep looping	

adj_exit_UNI:

	addi t4, t4, -1			; adjust UNI
	br endUNIloop			; terminate
	
endUNIloop: ret


; END:display_score


; BEGIN:restart_game
restart_game:
	ldw t1, BUTTONS+4(zero)	; t1 has edgecapture 
	addi t0, zero, 16		; value of 0b10000
	bge t1, t0, positive	; reset was pressed
	br negative

positive:

	addi t0, zero, 96
	addi t1, zero, 0

gsa_clear:
	beq t0, zero, initia
	stw zero, GSA(t1)
	addi t1, t1, 4
	addi t0, t0, -1
	br gsa_clear

initia:
	stw zero, BUTTONS+4(zero)	; clear edgecapture
	stw zero, SCORE(zero)	; initializing the score
	stw zero, HEAD_X(zero)	; initializing the Head coordinates
	stw zero, HEAD_Y(zero)
	stw zero, TAIL_X(zero)	; initializing the tail coordinates
	stw zero, TAIL_Y(zero)
	addi t0, zero, 4		; Move rightwards originally
	stw t0, GSA(zero)

	; PUSH operation on stack
	addi sp, sp, -4			; decrement stack pointer		
	stw ra, 0(sp)			; store previous ra value in stack due to incoming nested call
	
	call clear_leds
	call create_food
	call display_score
	call draw_array

	; POP operation on stack
	ldw ra, 0(sp)			; load in ra the appropriate return address
	addi sp, sp, 4			; increment stack pointer

	addi v0, zero, 1		; output is 1
ret

negative:
	addi v0, zero, 0 
ret
; END:restart_game

