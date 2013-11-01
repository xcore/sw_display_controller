#include <xs1.h>
#include <math.h>
#include "wave.h"

#define PI 3.14159265

void sine_wave(streaming chanend c_sine, short maxSampPerCyc)
{
	timer t;
	unsigned time;
	int data;

	t :> time;
	while (1){
		for (int i=1; i<=maxSampPerCyc; i++){
			data = 2048*sin(2*PI*i/maxSampPerCyc);
			t when timerafter(time+(XS1_TIMER_HZ/SAMP_FR.EQ)):> time;
			c_sine <: data;
		}
	}
}

void chirp_wave(streaming chanend c_chirp, short maxSampPerCyc)
{
	timer t;
	unsigned time, repeatTime;
	int data;

	t:>time;
	while(1){

		for (int s=maxSampPerCyc; s>=3; s--){
			t :> repeatTime;
			do {
				for (int i=1; i<=s; i++){
					data = 2048*sin(2*PI*i/s);
					t when timerafter(time+(XS1_TIMER_HZ/SAMP_FREQ)):> time;
					c_chirp <: data;
				}
			} while ((time-repeatTime)<(XS1_TIMER_HZ/8));
		}

		for (int s=3; s<=maxSampPerCyc; s++){
			t :> repeatTime;
			do {
				for (int i=1; i<=s; i++){
					data = 2048*sin(2*PI*i/s);
					t when timerafter(time+(XS1_TIMER_HZ/SAMP_FREQ)):> time;
					c_chirp <: data;
				}
			} while ((time-repeatTime)<(XS1_TIMER_HZ/8));
		}

	}
}
