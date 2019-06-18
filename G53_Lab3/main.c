#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/pushbuttons.h"

int basicIO();
int timers();
int interruption();


int main() {
	//basicIO();
	timers();
	//interruption();
}

int basicIO(){
	
	while (1) {
		
		//Map slider content to LEDs
		int slider_content = read_slider_switches_ASM();
		write_LEDs_ASM(slider_content);

		//Clear HEX displays if slider9 is on
		int bit_9 = slider_content & 0x200;
		if (bit_9 == 0x200){
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
			continue;
		}
		else {
			HEX_flood_ASM(HEX4 | HEX5);
		}
		
		//When button pressed, assign slider 4 least bits to HEX 3-0, depending on button pressed
		int value = slider_content & 0xF;
		switch (PB_data_is_pressed_ASM(read_PB_data_ASM())){
			case 0:	
				HEX_write_ASM(HEX0, value);
				break;
			case 1:	
				HEX_write_ASM(HEX1, value);
				break;
			case 2:	
				HEX_write_ASM(HEX2, value);
				break;
			case 3:	
				HEX_write_ASM(HEX3, value);
				break;
		}
	}
	return 0;
}

int timers (){

	HPS_TIM_config_t hps_tim0;
	HPS_TIM_config_t hps_tim1;

	int count0 = 0, count1 = 0, count2 = 0, count3 = 0 , count4= 0, count5 =0;
	int start = 0;

	hps_tim0.tim = TIM0;
	hps_tim0.timeout = 10000; //for the timer
	hps_tim0.LD_en = 1;
	hps_tim0.INT_en = 1;
	hps_tim0.enable = 1;
	
    hps_tim1.tim = TIM1;
	hps_tim1.timeout = 5000; //for the timer
	hps_tim1.LD_en = 1;
	hps_tim1.INT_en = 1;
	hps_tim1.enable = 1;

	HPS_TIM_config_ASM(&hps_tim0);
	HPS_TIM_config_ASM(&hps_tim1);

	HEX_write_ASM(HEX0|HEX1|HEX2|HEX3|HEX4|HEX5, 0); //setting the hexes to 0

	while(1){
		if(start){ //program starts means stopwatch starts
			if(HPS_TIM_read_INT_ASM(TIM0)){
				HPS_TIM_clear_INT_ASM(TIM0);
				if(++count0 == 10){ //increment digit until its 10
					count0 = 0; //reset it to 0 
					count1++; //increment the next digit
				}
				if(count1 == 10){	//if second digit reaches 10 reset it and increment next in line
					count1=0;
					count2++;
				}
				if(count2 == 10){	//if third digit reaches 10 reset it and increment next in line
					count2=0;
					count3++;
				}
				if(count3 == 6){	//if fourth digit reaches 6 reset it and increment next in line since minute was reached
					count3=0;
					count4++;
				}
				if(count4 == 10){	//if digit reaches 10 reset it and increment next in line
					count4=0;
					count5++;
				}
				if(count5 == 6){	//if digit reaches 6 reset it since an hour was reached (60 mins hence the 6)
					count5=0;					
				}

				HEX_write_ASM(HEX0, count0);
				HEX_write_ASM(HEX1, count1);
				HEX_write_ASM(HEX2, count2);
				HEX_write_ASM(HEX3, count3);
				HEX_write_ASM(HEX4, count4);
				HEX_write_ASM(HEX5, count5);
			}		
		}
		
		if(HPS_TIM_read_INT_ASM(TIM1)){
			HPS_TIM_clear_INT_ASM(TIM1);
	
			if(PB_data_is_pressed_ASM(read_PB_data_ASM())== 0){ //button 1 presse so start the program
				start = 1;
			}	

			if(PB_data_is_pressed_ASM(read_PB_data_ASM())== 1){ //button 2 pressed so pause program
				start = 0;
				while(1){
					if(PB_data_is_pressed_ASM(read_PB_data_ASM())== 0 || PB_data_is_pressed_ASM(read_PB_data_ASM())== 2){ //resume if start or reset
						start = 1;
						break;
					}
				}
			}
			if(PB_data_is_pressed_ASM(read_PB_data_ASM()) == 2){ //reset button is pressed
				count0 = 0;	
				count1 = 0;
				count2 = 0;
				count3 = 0;
				count4 = 0;
				count5 = 0;
				start = 0;

				HEX_write_ASM(HEX0, count0);
				HEX_write_ASM(HEX1, count1);
				HEX_write_ASM(HEX2, count2);
				HEX_write_ASM(HEX3, count3);
				HEX_write_ASM(HEX4, count4);
				HEX_write_ASM(HEX5, count5);
			}
		}
	}
	return 0;
}

int interruption(){
	HPS_TIM_config_t hps_tim0;

	int_setup(2, (int[]){199,73});
    int count0 = 0, count1 = 0, count2 = 0, count3 = 0 , count4= 0, count5 =0;
	int start = 0;

	hps_tim0.tim = TIM0;
	hps_tim0.timeout = 10000; 
	hps_tim0.LD_en = 1;
	hps_tim0.INT_en = 1;
	hps_tim0.enable = 1;

	HPS_TIM_config_ASM(&hps_tim0);

	HEX_write_ASM(HEX0|HEX1|HEX2|HEX3|HEX4|HEX5, 0); //setting the hexes to 0

	while(1){
		enable_PB_INT_ASM(PB0|PB1|PB2);	

		if(start){
			if(hps_tim_flag){//check the interrupt flag 
				hps_tim_flag = 0;
				if(++count0 == 10){ //increment digit until its 10
					count0 = 0; //reset it to 0 
					count1++; //increment the next digit
				}
				if(count1 == 10){	//if second digit reaches 10 reset it and increment next in line
					count1=0;
					count2++;
				}
				if(count2 == 10){	//if third digit reaches 10 reset it and increment next in line
					count2=0;
					count3++;
				}
				if(count3 == 6){	//if fourth digit reaches 6 reset it and increment next in line since minute was reached
					count3=0;
					count4++;
				}
				if(count4 == 10){	//if digit reaches 10 reset it and increment next in line
					count4=0;
					count5++;
				}
				if(count5 == 6){	//if digit reaches 6 reset it since an hour was reached (60 mins hence the 6)
					count5=0;					
				}

				HEX_write_ASM(HEX0, count0);
				HEX_write_ASM(HEX1, count1);
				HEX_write_ASM(HEX2, count2);
				HEX_write_ASM(HEX3, count3);
				HEX_write_ASM(HEX4, count4);
				HEX_write_ASM(HEX5, count5);

			}
		}

		if(button_flag == 0){ //if its 0 then we resume or start depending if you were paused or not
			start = 1;
		}

		if(button_flag == 1){ // if 1 we pause
			start = 0;	
			while(1) {
				if(button_flag == 0 || button_flag == 2){
					start = 1;
					break;
				}
			}
		}

		if(button_flag == 2){ //if 2 we reset
				count0 = 0;	
				count1 = 0;
				count2 = 0;
				count3 = 0;
				count4 = 0;
				count5 = 0;

				HEX_write_ASM(HEX0, count0);
				HEX_write_ASM(HEX1, count1);
				HEX_write_ASM(HEX2, count2);
				HEX_write_ASM(HEX3, count3);
				HEX_write_ASM(HEX4, count4);
				HEX_write_ASM(HEX5, count5);
		}
	}
	return 0;
}

