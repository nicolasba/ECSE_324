#include "./drivers/inc/vga.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/audio.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/wavetable.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/slider_switches.h"

float makeWave(float f, int t){
	
	//index = (f*t) mod 48000, index can have decimals
	int m = (f * t) / 48000;
	float index = (f * t) - m * 48000;
	
	int	floorIndex = (int) index;
	int ceilIndex = ((index - floorIndex) > 0)? floorIndex + 1 : floorIndex;
	
	return (1 - (index - floorIndex)) * sine[floorIndex] + (index - floorIndex) * sine[ceilIndex];	
}

void keyPressed(int *notes, int note, int *break_ptr, float **yValues, int amplitude){
	
	if (*break_ptr == 1){ 	//Found break, stop playing note
		notes[note] = 0;
		*break_ptr = 0;
	}
	else {
		if (notes[note] == 0)	//Key is not being played, start playing
			notes[note] = 1;
	}
	
	//Vga method 2
	int i = 0;
	int j = 0;
	int y = 0;

	//Clear previous points
	for (i = 0; i < 320; i++){
		VGA_draw_point_ASM(i, yValues[8][i], 0x0);
	}
	
	//Update wave display, depending on which notes are being played
	for (i = 0; i < 320; i++){
		y = 0;
		for (j = 0; j < 8; j++){
			if (notes[j] == 1){
				y += (120 - yValues[j][i]);
			}
		}
		yValues[8][i] = 120 - y * amplitude;// * amplitude;
		VGA_draw_point_ASM(i, yValues[8][i], 0xFFFF);
	}
}

int main (){
	
	int nbNotes = 8;
	int notes[nbNotes];		//0-7 to show which note is being played
	int counter = 0;		//t
	float signal = 0;			// TODO, try float
	int breakDetected = 0;

	//Volume and amplitude decay
	int amplitude = 5;		//Volume constant (signal * 5 feels like a good starting volume)
	int minAmplitude = 0;
	int maxAmplitude = 10;

	float maxSignal = 0;	//Used to find the ratio between played signal and maxSignal to display on screen

	int i = 0;
	int j = 0;

	//Timer setup
	HPS_TIM_config_t hps_tim0;
	int_setup(1, (int[]){199});

	hps_tim0.tim = TIM0;
	hps_tim0.timeout = 20;		 //48000Hz = every 20.83 microseconds
	hps_tim0.LD_en = 1;
	hps_tim0.INT_en = 1;
	hps_tim0.enable = 1;

	HPS_TIM_config_ASM(&hps_tim0);

	for (i = 0; i < nbNotes; i++)
		notes[i] = 0;
	
	//Order of notes is : low c, d, e, f, g, a, b, high c}
	float frequencies[] = {130.813, 146.832, 164.814, 174.614, 195.998, 220.000, 246.942, 261.626};
	float **notesWaves = (float**) malloc (nbNotes * sizeof (float*));

	//Setting musical notes sine wave
	for (i = 0; i < nbNotes; i++){
		notesWaves[i] = (float*) malloc (48000 * sizeof(float));
			
		for (j = 0; j < 48000; j++) {
			notesWaves[i][j] = /*(int)*/ makeWave(frequencies[i], j);
			//Find max signal for max amplitude
			if ((sine[j] * maxAmplitude * nbNotes) > maxSignal)
				maxSignal = sine[j] * maxAmplitude * nbNotes;
		}
	}
	
	//Vga method 2
	VGA_clear_pixelbuff_ASM();
	float **yValues = (float**) malloc ((nbNotes + 1) * sizeof (float*));
	
	for (i = 0; i < nbNotes + 1; i++){
		yValues[i] = (float*) malloc (320 * sizeof (float));
		for (j = 0; j < 320; j++){
			if (i == nbNotes){		//Last array will be used to hold previous points, initialized to flat line
				yValues[i][j] = 120;
				VGA_draw_point_ASM(j, yValues[i][j], 0xFFFF);
			}
			else
				yValues[i][j] = 120 - (((notesWaves[i][5 * j]) * 1.0 * 4) / maxSignal * 90);		//In one cycle of the lowest frequency there are 366 samples
		}
	}
	
	while(1){
			if(hps_tim_flag){	//check the interrupt flag 
				hps_tim_flag = 0;
				signal = 0;

				//Add signals
				for (i = 0; i < nbNotes; i++){
					if (notes[i]){
						signal += notesWaves[i][counter];// * decays[i];
						//decays[i] *= decayConstant;
					}
				}
				counter++;
				signal *= amplitude;
				//Sound
				//There should be no problem of full fifo, because sample of rate of audio codec is 48000Hz
				//and timer is set at a slightly lower frequency, but just in case
				while (!audio_read_wslc_ASM() || !audio_read_wsrc_ASM());	//Loop if wslc = 0 or wsrc = 0
				audio_write_data_ASM(signal, signal);			
			}
		
		//Reset t
		if (counter >= 48000)
			counter = 0;
		
		//Keyboard
		char key = 0;
		int isValid = read_ps2_data_ASM(&key);
	
		if (isValid){
			switch (key){
				case 0x1C:	//A
					keyPressed(notes, 0, &breakDetected, yValues, amplitude);
					break;	
				case 0x1B:	//S
					keyPressed(notes, 1, &breakDetected, yValues, amplitude);
					break;	
				case 0x23:	//D
					keyPressed(notes, 2, &breakDetected, yValues, amplitude);
					break;	
				case 0x2B:	//F
					keyPressed(notes, 3, &breakDetected, yValues, amplitude);
					break;	
				case 0x3B:	//J
					keyPressed(notes, 4, &breakDetected, yValues, amplitude);
					break;	
				case 0x42:	//K
					keyPressed(notes, 5, &breakDetected, yValues, amplitude);
					break;	
				case 0x4B:	//L
					keyPressed(notes, 6, &breakDetected, yValues, amplitude);
					break;	
				case 0x4C:	//;	
					keyPressed(notes, 7, &breakDetected, yValues, amplitude);
					break;	
				case 0x55:	//+
					if (amplitude < maxAmplitude) keyPressed(notes, 8, &breakDetected, yValues, amplitude++);
					break;
				case 0x4E:	//-
					if (amplitude > minAmplitude) keyPressed(notes, 8, &breakDetected, yValues, amplitude--);
					break;
				case 0xF0:	//Break code, make code should follow
					breakDetected = 1;
					break;
				default:
					breakDetected = 0;	//Undefined key should not affect break boolean
			}		
		}
	}
	return 0;
}
