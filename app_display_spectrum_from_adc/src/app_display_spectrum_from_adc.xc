
#include <platform.h>
#include <xs1.h>
#include <xs1_su.h>
#include <math.h>

#include "usb_tile_support.h"
#include "lcd.h"
#include "sdram.h"
#include "display_controller.h"
#include "fft.h"
#include "level_meter.h"


on tile[1] : lcd_ports lcdports = {	// on diamond slot of U16
  XS1_PORT_1I, XS1_PORT_1L, XS1_PORT_32A, XS1_PORT_1J, XS1_PORT_1K, XS1_CLKBLK_1 };
on tile[1] : sdram_ports sdramports = {	// on square slot of U16
  XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_2 };
on tile[0] : out port p_adc_trig = PORT_ADC_TRIGGER;

#define SAMP_FREQ 40000		// sampling frequency for ADC inputs
#define FFT_POINTS 256	// Number of signal samples chosen for FFT computation. It is double the level meter bands.
#define FFT_SINE sine_256	// Sine wave selected for FFT computation
#define LEV_METER_BANDS FFT_POINTS/4 	// Number of FFT points to be displayed

#define LOG_SPEC 1	// Set to 1 if log spectrum is taken; 0 otherwise
#if LOG_SPEC
#define MAX_FFT 70		// FFT limit on the display
#else
#define MAX_FFT 100
#endif

#define FFT_FULL_USE 0	// FFT computation in full use
#if (!FFT_FULL_USE)
#define FFT_UPDATE_RATE 10 	// Number of times FFT computation is done in a second
#endif

void magnitude_spectrum(int sig1[], int sig2[], unsigned magSpectrum[])
{
	int  im[FFT_POINTS];

	// Mixing signals
	for (int i=0; i<FFT_POINTS; i++)
	{
		sig1[i] += sig2[i];
		im[i] = 0;
	}

	// FFT
	fftTwiddle(sig1, im, FFT_POINTS);
	fftForward(sig1, im, FFT_POINTS, FFT_SINE);

	// Magnitude spectrum
	for (int i=0; i<FFT_POINTS; i++){
		magSpectrum[i] = sig1[i]*sig1[i] + im[i]*im[i];
#if LOG_SPEC
		magSpectrum[i] = (magSpectrum[i]>0)? 10*log(magSpectrum[i]):0;
#endif
	}

}


enum command {GET_SIG};
interface app_sigSamp_interface {
	void get_signal(unsigned cmd, int sig1[], int sig2[]);
};

void app(chanend c_dc, interface app_sigSamp_interface client c)
{
  unsigned frBufIndex=0, frBuf[2];
  int sig1[FFT_POINTS], sig2[FFT_POINTS];
  unsigned magSpec[FFT_POINTS];
  unsigned plotTime;
  timer t;

   // Create frame buffers
  frBuf[0] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  frBuf[1] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  display_controller_frame_buffer_init(c_dc, frBuf[0]);

  // Get signal segment from ADC and Display spectrum periodically
  t :> plotTime;
  while (1){

	  frBufIndex = 1-frBufIndex;

	  // Get signal samples from ADC
	  c.get_signal(GET_SIG, sig1, sig2);

	  // Take magnitude spectrum of mixed signal and display it
	  magnitude_spectrum(sig1, sig2, magSpec);
	  magSpec[0] = 0;	// Set DC component to 0
	  level_meter(c_dc, frBuf[frBufIndex], magSpec, LEV_METER_BANDS, MAX_FFT);
#if (!FFT_FULL_USE)
	  t when timerafter(plotTime+(XS1_TIMER_HZ/FFT_UPDATE_RATE)):> plotTime;
#endif
	  display_controller_frame_buffer_commit(c_dc,frBuf[frBufIndex]);
  }

}


void signal_sampler(chanend c_adc, interface app_sigSamp_interface server c)
{
  timer t;
  unsigned sampleTime;
  unsigned data[2], circBuf[2][FFT_POINTS], circBufPtr=0;

  // Configure and enable ADC
  adc_config_t adc_config = { { 0, 0, 0, 0, 0, 0, 0, 0 }, 0, 0, 0 };
  adc_config.input_enable[4] = 1;
  adc_config.input_enable[5] = 1;
  adc_config.samples_per_packet = 2;
  adc_config.bits_per_sample = ADC_8_BPS;
  adc_config.calibration_mode = 0;

  adc_enable(usb_tile, c_adc, p_adc_trig, adc_config);

  t :> sampleTime;
  while (1) {
	  select {

		  // Get signal samples from ADC at sampling time
		  case t when timerafter(sampleTime+(XS1_TIMER_HZ/SAMP_FREQ)):> sampleTime:
			  adc_trigger_packet(p_adc_trig, adc_config);
			  adc_read_packet(c_adc, adc_config, data);
			  circBuf[0][circBufPtr] = data[0]; circBuf[1][circBufPtr] = data[1];
			  circBufPtr = (circBufPtr+1)%FFT_POINTS;
		  break;

		  // Send signal samples
		  case c.get_signal(unsigned cmd, int sig1[], int sig2[]):
			  for (int i=0; i<FFT_POINTS; i++){
				  sig1[i] = circBuf[0][circBufPtr];
				  sig2[i] = circBuf[1][circBufPtr];
				  circBufPtr = (circBufPtr+1)%FFT_POINTS;
			  }
		  break;

	  }
  }
}


int main(){
	chan c_dc, c_lcd, c_sdram, c_adc;
	interface app_sigSamp_interface c;

	par {

		on tile[1]: app(c_dc, c);
		on tile[1]: display_controller(c_dc,c_lcd,c_sdram);
		on tile[1]: lcd_server(c_lcd,lcdports);
		on tile[1]: sdram_server(c_sdram,sdramports);

		on tile[0]: signal_sampler(c_adc,c);
        xs1_su_adc_service(c_adc);

	}

	return 0;
}

