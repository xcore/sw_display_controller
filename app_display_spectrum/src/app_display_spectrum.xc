
#include <platform.h>
#include <xs1.h>

#include "lcd.h"
#include "sdram.h"
#include "display_controller.h"
#include "fft.h"
#include "level_meter.h"
#include "wave.h"

on tile[1] : lcd_ports lcdports = {	// on diamond slot of U16
  XS1_PORT_1I, XS1_PORT_1L, XS1_PORT_32A, XS1_PORT_1J, XS1_PORT_1K, XS1_CLKBLK_1 };
on tile[1] : sdram_ports sdramports = {	// on square slot of U16
  XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_2 };

#define FFT_POINTS 64	// Number of data points chosen for FFT computation. It is double the level meter bands.
#define FFT_SINE sine_64	// Sine wave selected for FFT computation


void magnitude_spectrum(streaming chanend c_sig1, streaming chanend c_sig2, unsigned magSpectrum[])
{
	int sig_re[FFT_POINTS],  im[FFT_POINTS], temp;

	for (int i=0; i<FFT_POINTS; i++){

		// buffering
		c_sig1 :> sig_re[i];
		c_sig2 :> temp;

		// Mixing
		sig_re[i] += temp;
		im[i] = 0;

	}

	// fft
	fftTwiddle(sig_re, im, FFT_POINTS);
	fftForward(sig_re, im, FFT_POINTS, FFT_SINE);

	// magnitude spectrum
	for (int i=0; i<FFT_POINTS; i++)
		magSpectrum[i] = sig_re[i]*sig_re[i] + im[i]*im[i];

}


void app(chanend c_dc, streaming chanend c_sig1, streaming chanend c_sig2)
{
  unsigned frBufIndex=0, frBuf[2];
  unsigned magSpec[FFT_POINTS], maxSpec;

  // Create frame buffers
  frBuf[0] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  frBuf[1] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  display_controller_frame_buffer_init(c_dc, frBuf[0]);

  // Display spectrum periodically
  while (1){
	  frBufIndex = 1-frBufIndex;
	  magnitude_spectrum(c_sig1, c_sig2, magSpec);

	  maxSpec = 0;
	  for (int i=0; i<FFT_POINTS/2; i++)
		  maxSpec = (magSpec[i]>maxSpec)? magSpec[i]:maxSpec;
	  level_meter(c_dc, frBuf[frBufIndex], magSpec, FFT_POINTS/2, maxSpec);
	  display_controller_frame_buffer_commit(c_dc,frBuf[frBufIndex]);
  }

}


void main(){
	chan c_dc, c_lcd, c_sdram;
	streaming chan c_sig1, c_sig2;

	par {

		on tile[1]: app(c_dc, c_sig1, c_sig2);
		on tile[1]: display_controller(c_dc,c_lcd,c_sdram);
		on tile[1]: lcd_server(c_lcd,lcdports);
		on tile[1]: sdram_server(c_sdram,sdramports);

		// CHOICE 1
		on tile[1]: chirp_wave(c_sig1, FFT_POINTS);
		on tile[1]: chirp_wave(c_sig2, FFT_POINTS/4);

		// CHOICE 2
//		on tile[1]: sine_wave(c_sig1, FFT_POINTS);
//		on tile[1]: chirp_wave(c_sig2, FFT_POINTS/4);

		// CHOICE 3
//		on tile[1]: sine_wave(c_sig1, FFT_POINTS);
//		on tile[1]: sine_wave(c_sig2, FFT_POINTS/4);


	}
}

