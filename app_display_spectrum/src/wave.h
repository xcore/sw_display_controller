
#ifndef SINE_H_
#define SINE_H_

#define SAMP_FREQ 50000
void sine_wave(streaming chanend c_sine, short maxSampPerCyc);
void chirp_wave(streaming chanend c_chirp, short maxSampPerCyc);

#endif /* SINE_H_ */
