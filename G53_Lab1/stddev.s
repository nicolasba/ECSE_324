			.text
			.global _start

_start: 	
			LDR R4, =MAX 			/* Register R4 is a pointer to max location */
			LDR R5, =MIN	 		/* Register R5 is a pointer to min location */
			LDR R6, =STD_DEV		/* Register R6 is a pointer to std_dev location */
			LDR R2, [R6, #4]		/* Register R2 holds value N. */
			ADD R3, R6, #8			/* Register R3 points to the first element in the list. */
			LDR R0, [R3] 			/* Register R0 holds the first number. (This register acts like a max variable) */

MAX_LOOP: 	SUBS R2, R2, #1			/* Decrement the loop counter */
			BEQ RESET_POINTERS		/* End loop if counter has reached 0. */
			ADD R3, R3, #4 			/* Register R3 points to the next number in the list */
			LDR R1, [R3] 			/* Register R1 holds the next number in the list */
			CMP R0, R1 				/* Compare R0 and R1 values (R0 - R1)  */
			BGE MAX_LOOP			/* If (R0 - R1) > 0, no new max has been found, so loop again */
			MOV R0, R1				/* If (R0 - R1) < 0, a new max has been found, so update R0 */
			B MAX_LOOP				/* Loop again */

RESET_POINTERS:
			STR R0, [R4]			/* Max loop is over, store max value in result location */
			LDR R2, [R6, #4]		/* Reset pointers as initially to find min */
			ADD R3, R6, #8			/* Register R3 points to the first element in the list. */
			LDR R0, [R3] 			/* Register R0 holds the first number. (This register acts like a min variable) */

MIN_LOOP: 	SUBS R2, R2, #1			/* Decrement the loop counter */
			BEQ DONE 				/* End loop if counter has reached 0. */
			ADD R3, R3, #4 			/* Register R3 points to the next number in the list */
			LDR R1, [R3] 			/* Register R1 holds the next number in the list */
			CMP R0, R1 				/* Compare R0 and R1 values (R0 - R1)  */
			BLE MIN_LOOP			/* If (R0 - R1) <= 0, no new min has been found, so loop again */
			MOV R0, R1				/* If (R0 - R1) > 0, a new min has been found, so update R0 */
			B MIN_LOOP				/* Loop again */

DONE:		STR R0, [R5]			/* Min Loop is over, store min value in min location */
			LDR R7, [R4]			/* Load max value */
			LDR R8, [R5]			/* Load min value */
			SUBS R9, R7, R8			/* Register R9 will hold max - min value */
			LSR R9, R9, #2			/* Shifting by 2 bits is same as dividing by 4 */
			STR R9, [R6] 			/* Store result in memory assigned to std deviation */

END: 		B END					/* Infinite loop */

MAX: 		.word	0				/* Memory assigned to hold max value */	
MIN: 		.word	0				/* Memory assigned to hold min value */
STD_DEV:	.word 	0				/* Memory assigned to hold std_dev */
N: 			.word 	7 				/* Memory assigned to hold number of entries in the list */
NUMBERS: 	.word 	4, 5, 3, 6	 	/* Memory assigned to hold list of entries */		
			.word 	1, 17, 2
