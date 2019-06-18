			.text
			.global _start

_start: 	
			LDR R4, =RESULT 		/* Register R4 is a pointer to result location */
			LDR R2, [R4, #4]		/* Register R2 is a pointer to N. */
			ADD R3, R4, #8 			/* Register R3 points to the first element in the list. */
			LDR R0, [R3] 			/* Register R0 holds the first number. (This register acts like a max variable) */

LOOP: 		SUBS R2, R2, #1			/* Decrement the loop counter */
			BEQ DONE 				/* End loop if counter has reached 0. */
			ADD R3, R3, #4 			/* Register R3 points to the next number in the list */
			LDR R1, [R3] 			/* Register R1 holds the next number in the list */
			CMP R0, R1 				/* Compare R0 and R1 values (R0 - R1)  */
			BGE LOOP				/* If (R0 - R1) > 0, no new max has been found, so loop again */
			MOV R0, R1				/* If (R0 - R1) < 0, a new max has been found, so update R0 */
			B LOOP					/* Loop again */

DONE:		STR R0, [R4]			/* Loop is over, store max value in result location */

END: 		B END					/* Infinite loop */

RESULT: 	.word	0				/* Memory assigned to hold result */	
N: 			.word 	7 				/* Memory assigned to hold number of entries in the list */
NUMBERS: 	.word 	4, 5, 3, 6	 	/* Memory assigned to hold list of entries */		
			.word 	1, 8, 2
