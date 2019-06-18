			.text
			.equ PIXEL_BASE, 0xC8000000
			.equ PIXEL_LAST_ADRESS, 0xC803BE7E
			.equ CHAR_BASE, 0xC9000000
			.equ CHAR_LAST_ADRESS, 0xC9001DCF
			.global VGA_clear_charbuff_ASM
			.global VGA_clear_pixelbuff_ASM
			.global VGA_write_char_ASM
			.global VGA_write_byte_ASM
			.global VGA_draw_point_ASM

VGA_clear_charbuff_ASM:
			PUSH {R3, R4, R5, LR}				/* Callee save */	
			LDR R3, =CHAR_BASE   				/* Pointer to base char location */
			LDR R4, =CHAR_LAST_ADRESS			/* Pointer to last char location */
			MOV R5, #0							/* Constant for clear */
LOOP_1:	
			STRB R5, [R3], #1					/* Post-increment by 1 to visit all char buffer locations */
			CMP R3, R4
			BNE LOOP_1							/* Not reached last location yet */
			POP {R3, R4, R5, LR}
			BX LR
			
VGA_clear_pixelbuff_ASM:
			PUSH {R3, R4, R5, LR}				/* Callee save */	
			LDR R3, =PIXEL_BASE   				/* Pointer to base pixel location */
			LDR R4, =PIXEL_LAST_ADRESS			/* Pointer to last pixel location */
			MOV R5, #0						
LOOP_2:	
			STRH R5, [R3], #2					/* Post-increment by 2 to visit all pixel buffer locations */
			CMP R3, R4
			BNE LOOP_2							/* Not reached last location yet */
			POP {R3, R4, R5, LR}
			BX LR

VGA_write_char_ASM:
			PUSH {R3, R4}
			MOV R4, #0							
			CMP R0, R4							/* If x < 0, leave */
			BXLT LR		
			CMP R1, R4							/* If y < 0, leave */
			BXLT LR
			MOV R4, #79							
			CMP R0, R4							/* If x > 79, leave */
			BXGT LR	
			MOV R4, #59							
			CMP R1, R4							/* If y > 59, leave */
			BXGT LR			
	
			LDR R3, =CHAR_BASE					/* Pointer to base char location */
			ADD R3, R3, R0						/* Point to x coordinate */
			ADD R3, R3, R1, LSL #7				/* Point to y coordinate */
			STRB R2, [R3]						/* Store char */
			POP {R3, R4}
			BX LR

VGA_write_byte_ASM:
			PUSH {R3, R4, LR}
			MOV R4, #78						
			CMP R0, R4							/* If x > 78, leave, (x + 1 should be <= 79 ) */
			BXGT LR							
			
			LDR R4,=0xF						
			AND R4, R4, R2						/* Move lower half (4 bits) of third parameter (R2) into R4 */
			MOV R2, R2, LSR #4					/* R2 will hold upper half of its original value */
			
			CMP R2, #9							/* Display upper half first */
			SUBGT R2, R2, #10					/* If hex value to display is > 9, display A-F : ascii(A) = 65 */
			ADDGT R2, R2, #65
			ADDLE R2, R2, #48						/* Otherwise display numbers 0-9: ascii(0) = 48 */
			BL VGA_write_char_ASM				/* R0 holds x, R1 holds y, R2 holds value char to display */
			
			MOV R2, R4
			CMP R2, #9							/* Display lower half */
			SUBGT R2, R2, #10					/* If hex value to display is > 9, display A-F : ascii(A) = 65 */
			ADDGT R2, R2, #65
			ADDLE R2, R2, #48					/* Otherwise display numbers 0-9: ascii(0) = 48 */
			ADD R0, R0, #1
			BL VGA_write_char_ASM				/* R0 holds x + 1, R1 holds y, R2 holds value char to display */

			POP {R3, R4, LR}
			BX LR

VGA_draw_point_ASM:	
			PUSH {R3, R4}
			MOV R4, #0							
			CMP R0, R4							/* If x < 0, leave */
			BXLT LR		
			CMP R1, R4							/* If y < 0, leave */
			BXLT LR
			LDR R4,=0x13F						/* 319 base 10 = 13F base 16 */
			CMP R0, R4							/* If x > 319, leave */
			BXGT LR	
			MOV R4, #239							
			CMP R1, R4							/* If y > 239, leave */
			BXGT LR
				
			LDR R3, =PIXEL_BASE					/* Pointer to base pixel location */
			ADD R3, R3, R0, LSL #1				/* Point to x coordinate */
			ADD R3, R3, R1, LSL #10				/* Point to y coordinate */
			STRH R2, [R3]						/* Store color */
			POP {R3, R4}
			BX LR
