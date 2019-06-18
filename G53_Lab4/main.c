#include <stdio.h>
#include "./inc/VGA.h"
#include "./inc/ps2_keyboard.h"
#include "./inc/pushbuttons.h"
#include "./inc/slider_switches.h"
#include "./inc/audio_driver.h"

int vga();
int keyboard();
int audio();

void test_char(){
	int x,y;
	char c = 0;
	for(y=0; y<=59; y++){
		for(x=0; x<=79;x++){
			VGA_write_char_ASM(x,y,c++);
		}	
	}
}

void test_byte(){
	int x,y;
	char c=0;
	
	for(y=0; y<=59; y++){
		for(x=0;x<=79;x +=3){
			VGA_write_byte_ASM(x,y,c++);
		}
	}
} 

void test_pixel(){
	int x,y;
	unsigned short color = 0;
	
	for(y=0; y<=239; y++){
		for(x=0;x<=319;x++){
			VGA_draw_point_ASM(x,y,color++);
		}
	}
}

int main(){
	//vga();
	keyboard();
	//audio();
	return 0;
}

int vga(){
	
	while (1){
		switch (PB_data_is_pressed_ASM(read_PB_data_ASM())){
			case 0:			//Button 0
				if (read_slider_switches_ASM() == 0)
					test_char();
				else
					test_byte();			//If any slider is on
				break;
			case 1:			//Button 1
				test_pixel();
				break;
			case 2:			//Button 2
				VGA_clear_charbuff_ASM();
				break;
			case 3:			//Button 3
				VGA_clear_pixelbuff_ASM();
				break;
		};
	}
	return 0;
} 

int keyboard(){
	int x = 0; //x coord
	int y = 0; //y coord
	char c; //data held

	VGA_clear_charbuff_ASM();
	VGA_clear_pixelbuff_ASM();

	while(1){
		int isValid = read_PS2_data_ASM(&c);

		if(isValid){
			VGA_write_byte_ASM(x,y,c); //write to screen
			x+=3; //increment by 3 since a byte displays 2 chars and we need a 3rd one for a space

			if(x>79){ //if at the end of the screen horizontally
				x=0;
				y+=1;
			}	
			if(y>59){ //check if vertically end of screen
				x=0;
				y=0;
				VGA_clear_charbuff_ASM();
			}	
		
		}


	}
}

int audio(){
	int s =0; //default sample rate = 48000samples/sec. We want 100Hz so 480 samples, split in half for 240 zeros and 1's 

	while(1){
		for(s = 0 ; s< 240; s++){ //write all 1s to audio
			if(write_int_audio_ASM(0x00FFFFFF) != 1){
				s--; //decrement if empty
			}
		}
		
		for(s=0; s<240; s++){
			if(write_int_audio_ASM(0x00000000) != 1){ //write 0s to audio
				s--; 
			}
		}
	}
}
