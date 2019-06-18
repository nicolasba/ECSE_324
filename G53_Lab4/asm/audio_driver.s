			.text
			.equ FIFO, 0xFF203044
			.equ LEFT, 0xFF203048
			.equ RIGHT, 0xFF20304C
			.global write_int_audio_ASM

write_int_audio_ASM:
		PUSH {R1-R6, LR}
		LDR R1, = FIFO //fifo location
		LDR R1, [R1] //get the value
		LSR R1, #16		//get wsrc by right shifting by 2^16 for the 16th bit
		LDRB R2, [R1]  //R2 holds the wsrc
		LSR R1, #8		//get wlsc with a right shift of 2^8 to read the bits located at the bits 24-31
		LDRB R3, [R1]	//r3 has wlsc
		CMP R2, #0
		BEQ DONE 	//exit if there is no more space in wsrc
		CMP R3, #0
		BEQ DONE   //exit if no more space in wlsc
		LDR R4, =LEFT	//left data
		LDR R5, =RIGHT //right data
		STR R0, [R5]  //store r0 in right
		STR R0, [R4]  //store r0 in left
	
		MOV R0, #1	//set to 1 for the change
		POP {R1-R6, LR}
		BX LR

DONE:	MOV R0, #0	//there is no more space so set change to 0
		BX LR

		POP {R1-R6, LR}
		BX LR

		.end
