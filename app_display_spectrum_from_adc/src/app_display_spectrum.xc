
#include <platform.h>
#include <xs1.h>
#include <xs1_su.h>

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

#define SAMP_FREQ 50000		// sampling frequency for ADC inputs
#define FFT_UPDATE_DELAY XS1_TIMER_HZ/2	// Delay for FFT update on the display
#define FFT_POINTS 64	// Number of data points chosen for FFT computation. It is double the level meter bands.
#define FFT_SINE sine_64	// Sine wave selected for FFT computation

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
	for (int i=0; i<FFT_POINTS; i++)
		magSpectrum[i] = sig1[i]*sig1[i] + im[i]*im[i];

}


void app(chanend c_dc, chanend c_adc)
{
  timer t;
  unsigned plotTime, sampleTime;
  unsigned frBufIndex=0, frBuf[2], data[2];
  int sig1[FFT_POINTS], sig2[FFT_POINTS];
  unsigned magSpec[FFT_POINTS];

  // Configure and enable ADC
  adc_config_t adc_config = { { 0, 0, 0, 0, 0, 0, 0, 0 }, 0, 0, 0 };
  adc_config.input_enable[4] = 1;
  adc_config.input_enable[5] = 1;
  adc_config.samples_per_packet = 2;
  adc_config.bits_per_sample = ADC_8_BPS;
  adc_config.calibration_mode = 0;

  adc_enable(usb_tile, c_adc, p_adc_trig, adc_config);

  // Create frame buffers
  frBuf[0] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  frBuf[1] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
  display_controller_frame_buffer_init(c_dc, frBuf[0]);

  // Display spectrum periodically
  t :> plotTime;
  while (1){

	  frBufIndex = 1-frBufIndex;

	  // Get signal samples from ADC
	  t :> sampleTime;
	  for (int i=0; i<FFT_POINTS; i++){
		  adc_trigger_packet(p_adc_trig, adc_config);
 		  adc_read_packet(c_adc, adc_config, data);
		  sig1[i] = data[0]; sig2[i] = data[1];
		  t when timerafter(sampleTime+(XS1_TIMER_HZ/SAMP_FREQ)):> sampleTime;
	  }

	  magnitude_spectrum(sig1, sig2, magSpec);
	  magSpec[0] = 0;	// Set DC component to 0
	  level_meter(c_dc, frBuf[frBufIndex], magSpec, FFT_POINTS/2);
	  t when timerafter(plotTime+FFT_UPDATE_DELAY):> plotTime;
	  display_controller_frame_buffer_commit(c_dc,frBuf[frBufIndex]);
  }

}


int main(){
	chan c_dc, c_lcd, c_sdram, c_adc;

	par {

		on tile[0]: app(c_dc, c_adc);
		on tile[1]: display_controller(c_dc,c_lcd,c_sdram);
		on tile[1]: lcd_server(c_lcd,lcdports);
		on tile[1]: sdram_server(c_sdram,sdramports);
        xs1_su_adc_service(c_adc);

	}

	return 0;
}

