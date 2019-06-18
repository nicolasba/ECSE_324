			.text
			.global _start

_start: 	
			LDR R1, N			/* Register R1 holds number of elements */
			ADD R1, R1, #1
			LDR R2, =ARRAY 		/* R2 holds pointer to first element in array */
			LDR R3, SUM			/* Holds value of sum */
			
AVG_LOOP:
			SUBS R1, R1, #1		/* Decrement the loop counter */
			BEQ COMPUTE_AVG		/* Go back to outer loop if counter has reached */	
			LDR R4, [R2]		/* Holds element of array */
			ADD R3, R3, R4 		/* Adds total sum to element of array */
			ADD R2, R2, #4		/* R2 points to next element in array */
			B AVG_LOOP

COMPUTE_AVG:
			LDR R5, LOG         /* Holds value of log N */
			ASR R3, R3, R5		/* Shifts right sum by log N (divides by N) */
			LDR R1, N			/* Reload content of N in R1 */
			ADD R1, R1, #1
			LDR R2, =ARRAY		/* R2 points to first element in array */
			B SUBSTRACT_LOOP	/* Go to loop that subtracts average from every element */

SUBSTRACT_LOOP:
			SUBS R1, R1, #1		/* Decrement the loop counter */
			BEQ END				/* Go back to outer loop if counter has reached */	
			LDR R4, [R2]		/* Register R2 points to the actual element in the array. */
			SUBS R4, R4, R3 	/* Subtract average from element */
			STR R4, [R2]		/* Store new element of array back into the array. */
			ADD R2, R2, #4 		/* R2 points to next element in array */
			B	 SUBSTRACT_LOOP

END: 		B 	END					/* Infinite loop */

SUM:		.word 	0
N: 			.word 	8 				/* Memory assigned to hold number of entries in the list */
LOG:		.word   3
ARRAY: 		.word 	1, 2, 3, 4	 	/* Memory assigned to hold list of entries */		
			.word 	6, 7, 8, 9
