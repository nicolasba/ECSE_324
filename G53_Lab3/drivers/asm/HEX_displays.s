			.text
			.equ HEX_BASE, 0xFF200020
			.global HEX_clear_ASM
			.global HEX_flood_ASM
			.global HEX_write_ASM

HEX_clear_ASM:
			PUSH {R0, R2, R7}		/* Callee save */
			PUSH {LR}				/* Callee save */
			MVN R0, R0	 			/* Complement R0 */
			MOV R2, #255			/* Segment constant to store in every display (FF for turned on) */
			MOV R7, #10 			/* Arbitrary number assigned to differentiate calls from clear to setup*/
			BL HEX_setup			/* Call subroutine that sets up registers to use */
			POP {LR}				/* Callee save */
			POP {R0, R2, R7}		/* Callee save */
			BX LR				

HEX_flood_ASM:
			PUSH {R2, R7}			/* Callee save */
			PUSH {LR}				/* Callee save */
			BL HEX_clear_ASM		/* Clear passed parameters to be able to add segment constant (FF) without
									/* modifying the displays that were not included in the params */
			MOV R2, #255			/* Segment constant to store in every display (FF for turned on) */
			MOV R7, #0				/* Differentiate from clear () */
			BL HEX_setup			/* Call subroutine that sets up registers to use */
			POP {LR}				/* Callee save */
			POP {R2, R7}			/* Callee save */
			BX LR	

HEX_write_ASM:
			PUSH {R2, R3, R6, R7}	/* Callee save */
			PUSH {LR}				/* Callee save */
			BL HEX_clear_ASM		/* Clear passed parameters to be able to add segment constant(value) without
									/* modifying the displays that were not included in the params */
			MOV R7, #0				/* Differentiate from clear () */
			MOV R6, #4				/* Will multiply passed value of character by 4 to search in array*/
			MUL R1, R1, R6			/* Multiply parameter value by 4 to displace the SEGMENTS_VALUES pointer */
			LDR R3, =SEGMENT_VALUES /* Holds location to array of segment values */
			LDR R2, [R3, R1]		/* Load nth element of array, will be segment constant */
			BL HEX_setup			/* Call subroutine that sets up registers to use */
			POP {LR}				/* Callee save */
			POP {R2, R3, R6, R7}	/* Callee save */
			BX LR	

HEX_setup:
			PUSH {R1, R2, R3, R4, R8}	/* Callee save */
			PUSH {LR}				/* Callee save */

			LDR R1, =HEX_BASE		/* R1 holds dedicated location for HEX displays (3-0). The rest are at R1 + 16 */
			PUSH {R2}				/* Save segments constant in stack */
			MOV R3, #0				/* Holds counter for number of displays (0-6) times 4, useful for bit shift */
			LDR R4, [R1]			/* Holds result to store in memory */
			CMP R7, #10				/* Check whether call is coming from clear() */
			MOVEQ R4, #0			/* Clear needs to start with 0 as result, other functions need to start
									/* with values already in memory */
			BL HEX_loop				/* Call subroutine that will check whether a HEX display was passed as parameter */
			CMP R7, #10				/* Check whether call is coming from clear() */
			LDREQ R8, [R1]			/* If call from clear(), load content in display */
			ANDEQ R4, R4, R8		/* By ANDing with R4, which contains 0 for all params that are included 
									to clear and FF for all those that are not, only the displays that are
									to be cleared will be cleared, the rest will be unchanged */
			STR R4, [R1]			/* Store result in memory */

			ADD R1, R1, #16			/* Go to next location for HEX displays (5-4) */
			POP {R2}				/* Retrieve segments constant */
			MOV R3, #0				/* Reset counter for next displays location */
			LDR R4, [R1]			/* Holds result to store in memory */
			CMP R7, #10				/* Check whether call is coming from clear() */
			MOVEQ R4, #0			/* Clear needs to start with 0 as result, other functions need to start
									/* with values already in memory */
			BL HEX_loop				/* Call subroutine that will check whether a HEX display was passed as parameter */
			CMP R7, #10				/* Check whether call is coming from clear() */
			LDREQ R8, [R1]			/* If call from clear(), load content in display */
			ANDEQ R4, R4, R8		
			STR R4, [R1]			/* Store result in memory */

			POP {LR}				/* Callee save */
			POP {R1, R2, R3, R4, R8}	/* Callee save */
			BX LR	

HEX_loop:		
			PUSH {R5}				/* Callee save */
			MOV R5,	#1				/* Value that will be logical ANDed with hex value (1)*/
			AND R5, R5, R0			/* If HEX_t value && 0x1 = 0x1, then the hex display at the given counter is included */ 	
			CMP R5, #1				/* If = 0x1 */
			ADDEQ R4, R4, R2, LSL R3	/* Left Shift constant to add to result by number of bits determined by counter */
			LSR R0, R0, #1			/* Shift right HEX_t value by 1 bit to check for every display */
 			ADD R3, R3, #8			/* Counter + 8 (1 byte for each display)  */
			POP {R5}				/* Callee save */
			CMP R3, #32				/* Compare counter < 32 (max left shift should be by 12 bits) */
			BLT HEX_loop			/* If counter is less than 16, loop  */
			BX LR					
			
SEGMENT_VALUES: 	
			.word 	0x3F, 0x06, 0x5B, 0x4F	 	/* Memory assigned to hold hex segment values for every value (0-15) */		
			.word 	0x66, 0x6D, 0x7D, 0x07
			.word 	0x7F, 0x6F, 0x77, 0x7C
			.word 	0x39, 0x5E, 0x79, 0x71

			.end
