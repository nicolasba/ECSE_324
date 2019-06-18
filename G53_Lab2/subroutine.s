			.text
			.global _start

_start: 	
			LDR R4, =NUMBERS		/* Register R4 is a pointer to array */
			LDR R5, N				/* Register R5 holds the number of values in array */
			LDR R0, [R4]			/* R0 holds max value and R1 holds value to compare */
			LDR R1, [R4], #4	
			SUBS R5, R5, #1			/* Decrement counter */
			BLGE FILL_STACK			/* If there are more than 2 parameters, push the rest to stack */
			LDR R5, N				/* Restore number of elements to compare elements */
			B 	COMPARE				

FILL_STACK: 	
			LDR R2, [R4], #4		/* Load next element in array */
			PUSH {R2}				/* Push it to stack */
			SUBS R5, R5, #1			/* Decrement counter */
			BXEQ LR					/* If counter is 0, leave subroutine */
			B FILL_STACK			/* If counter is greater than 0, loop */

COMPARE:
			SUBS R5, R5, #1			/* Decrement counter */
			BEQ END					/* If 0, end */	
			POP {R1}				/* Pop stack into R1 */
			BL 	MAX 				/* Call subroutine */
			B 	COMPARE				/* Loop for every element in stack */
MAX: 		
			PUSH {R4-R12}			/* Save state */
			CMP R0, R1 				/* Compare R0 and R1 values (R0 - R1)  */
			MOVLT R0, R1			/* If (R0 - R1) > 0, no new max has been found, so loop again */
			POP {R4-R12}			/* Restore state */
			BX LR					/* Leave subroutine */

END: 		B END					/* Infinite loop */

N: 			.word 	7				/* Memory assigned to hold number of entries in the list */
NUMBERS: 	.word 	4, 5, 3, 6	 	/* Memory assigned to hold list of entries */		
			.word 	1, 8, 2

