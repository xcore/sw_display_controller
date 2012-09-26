#ifndef TRANSITIONS_H_
#define TRANSITIONS_H_

#define MAX_DITHER      (256) //best be a power of two
#define MAX_ALPHA_BLEND (32)  //NEVER change this!


unsigned transition_wipe(chanend c, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames, unsigned cur_fb_index);

unsigned transition_slide(chanend c, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames, unsigned cur_fb_index);

unsigned transition_dither(chanend c, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames, unsigned cur_fb_index);

unsigned transition_alpha_blend(chanend c, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames, unsigned cur_fb_index);

unsigned transition_roll(chanend c, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames, unsigned cur_fb_index);
    
#endif /* TRANSITIONS_H_ */
