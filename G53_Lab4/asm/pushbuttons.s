			.text
			.equ DATA, 0XFF200050
			.equ EDGECAPTURE, 0xFF20005C
			.equ INTERRUPT, 0xFF200058
			.global read_PB_data_ASM
			.global PB_data_is_pressed_ASM
			.global read_PB_edgecap_ASM
			.global PB_edgecap_is_pressed_ASM
			.global	PB_clear_edgecp_ASM
			.global	enable_PB_INT_ASM
			.global disable_PB_INT_ASM //names and order from header files

read_PB_data_ASM:		LDR R1, =DATA
						LDR R0, [R1]
						BX LR

PB_data_is_pressed_ASM:	CMP R0, #8 //if pushbutton data is 8 branch
						BGE P3
						CMP R0, #4 //if 4 branch
						BGE P2
						CMP R0, #2	//if 2 branch
						BGE P1
						CMP R0, #1 //if 1 branch
						BGE P0
	
						MOV R0, #4 //else set to none
						BX LR

P3:						MOV R0, #3 //button 3
						BX LR

P2:						MOV R0, #2 //button 2
						BX LR

P1:						MOV R0, #1 //button 1
						BX LR

P0:						MOV R0, #0 //button 0
						BX LR

read_PB_edgecap_ASM:	LDR R1, =EDGECAPTURE
						LDR R0, [R1]
						BX LR

PB_edgecap_is_pressed_ASM:	MOV R1, #4
							TST R0, #8
							MOVNE R1, #3
							TST R0, #4
							MOVNE R1, #2
							TST R0, #2
							MOVNE R1, #1
							TST R0, #1
							MOVNE R1, #0
							MOV R0, R1
							BX LR

PB_clear_edgecp_ASM:		LDR R1, =EDGECAPTURE
							MOV R2, #0xFFFFFFFF //clear all
							STR R2, [R1]
							BX LR

enable_PB_INT_ASM:			LDR R1, =INTERRUPT
							LDR R3, [R1]
							CMP R1, #0 			//if r1 is equal to 0 branch to store r0
							BEQ STORE
							ORR R2, R0, R3 //otherwise use orr to not change the values
							STR R2, [R1]	//and then store the result
							BX LR

STORE:						STR R0, [R1]
							BX LR

disable_PB_INT_ASM:			LDR R1, =INTERRUPT
							LDR R1, [R1]
							MVN R0, R0  //complement r0
							AND R0, R0, R1		//and it with r1 to remove the values which dont match
							STR R0, [R1]
							BX LR
				
							.end
