			.text
			.global _start

_start: 	
			LDR R4, N				/* R4 holds N at a given time in the subroutine */	
			SUBS R4, R4, #1			/* Magic trick */
			MOV R0, #0				/* R0 will store the result of fib (N), starts at 0 */
			BL 	FIB					/* Call subroutine */	
			B 	END

FIB: 			
			CMP R4, #2				/* If R4 is less than 2, subroutine should add +1 to R0 (result) and return */
			ADDLT R0, R0, #1		/* Add 1 to result (if N < 2)*/
			BXLT LR					/* Leave recursive subroutine (if N < 2)*/
			SUBS R4, R4, #1			/* Decrease N by 1*/
			PUSH {R4}				/* Save current value of N before calling subroutine */
			PUSH {LR}				/* Save current value of LR before calling subroutine */
			BL	FIB					/* Recursive call to subroutine */
			POP	{LR}				/* Restore current value of N before calling subroutine */
			POP {R4}				/* Restore current value of LR before calling subroutine */
			SUBS R4, R4, #1			/* Since N was already decreased by 1, this will be N - 2 */
			PUSH {R4}				/* Save current value of N before calling subroutine */	
			PUSH {LR}				/* Save current value of LR before calling subroutine */
			BL 	FIB					/* Recursive call to subroutine */
			POP {LR}				/* Restore current value of N before calling subroutine */
			POP {R4}				/* Restore current value of LR before calling subroutine */
			BX LR					/* Leave subroutine */

END: 		B END					/* Infinite loop */

N: 			.word 	13				/* Program will compute fib(N) */
