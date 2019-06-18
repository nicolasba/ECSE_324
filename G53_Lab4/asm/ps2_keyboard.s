			.text
			.equ PS2DATA, 0xFF200100
			.global read_PS2_data_ASM

read_PS2_data_ASM:
		LDR R1, =PS2DATA 			//the data location
		LDR R2, [R1]				//this puts the string of the data
		AND R4, R2, #0x8000 		//get rvalid by anding
		CMP R4, #0					//check if the rvalid will be 0 or 1
		BEQ INVALID  				//if 0 invalid branch
		B VALID						//if 1 valid branch

VALID:	
		MOV R4, #255				//Consider only 8 rightmost bits
		AND R4, R2, R4 				//and ps2data 
		STRB R4, [R0]  				//data is stored 
		MOV R0, #1					//return 1
		BX LR

INVALID:
		MOV R0, #0 					//return 0
		BX LR

		.end
