			.text
			.global _start

_start: 	
			LDR R2, FLAG			/* Register R2 holds value of sorted flag (false/true) */
			
OUTER_LOOP:
			CMP R2, #1				/* Compare R2 and 1 (R2 - 1). TRUE=1 - 1 = 0 */
			BEQ END					/* End loop if sorted flag is true */
			ADD R2, R2, #1			/* Set sorted flag to true */		
			LDR R0, =ARRAY			/* Register R0 holds pointer to start of array. */
			LDR R1, N				/* Register R1 holds value N. */
			B 	INNER_LOOP 			/* Start inner loop */

INNER_LOOP:
			SUBS R1, R1, #1			/* Decrement the loop counter */
			BEQ OUTER_LOOP			/* Go back to outer loop if counter has reached 0. */
			LDR R3, [R0]			/* Register R2 points to the actual element in the array. */
			LDR R4, [R0, #4]		/* Register R2 points to the next element in the array. */
			CMP R3, R4				/* Compare R2 and R3 values (R2 - R3)  */
			BGT SWAP				/* If R2 > R3, swap values because array has to be sorted in ascending order */
			B 	NEXT_ELEMENT			

NEXT_ELEMENT:
			ADD R0, R0, #4			/* R0 points to next element in array */
			B INNER_LOOP			/* Restart inner loop */

SWAP: 		
			STR R3, [R0, #4]		/* Store R3 (actual element) in following location */
			STR R4, [R0]			/* Store R4 (next element) in present location */
			LDR R2, FLAG			/* Reset sorted flag to false */
			B 	NEXT_ELEMENT		/* Shift pointer of array to next element*/

END: 		B 	END					/* Infinite loop */


N: 			.word 	9 				/* Memory assigned to hold number of entries in the list */
FLAG:		.word   0				/* Memory assigned to hold value of sorted flag */
ARRAY: 		.word 	4, 5, 3, 6	 	/* Memory assigned to hold list of entries */		
			.word 	1, 17, 2, -1, 10
