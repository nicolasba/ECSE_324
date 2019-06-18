			.text
			.global _start

_start: 	
			LDR R0, =ARRAY 			/* R0 holds pointer to first element in array */
			LDR R1, N				/* R1 holds the number of elements in array */
			LDR R3, =0xFFFF5BB0		/* R3 holds pointer to stack located at specified address */

PUSH_B:
			LDR R2, [R0], #4		/* Load one value from array in R2 at the time and shift array pointer to next element*/
			STR R2, [R3, #-4]!		/* Push value in R2 to stack */
			SUBS R1, R1, #1			/* Decrement the loop counter */
			BEQ POP_B				/* Go to pop branch if counter has reached 0*/	
			B PUSH_B				/* Loop */

POP_B:		
			LDMIA R3!, {R4-R6}		/* Pop the 3 values at the top of the stack to R4-R6 */
			B END						

END:		B END
	
ARRAY: 		.word 	1, 2, 3, 4	 	/* Memory assigned to hold list of entries */		
			.word 	6, 7, 8, 9
N: 			.word 	8 				/* Memory assigned to hold number of entries in the list */
