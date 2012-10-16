#ifndef TRANSITIONS_H_
#define TRANSITIONS_H_

#define MAX_DITHER      (256) //best be a power of two
#define MAX_ALPHA_BLEND (32)  //NEVER change this!

/** \brief Transition effect: A -> B as a wipe, i.e. B wipes to A from the right.
 *
 * \param server The channel from the client application to the display_controller.
 * \param frame_buffer An array of the frame buffer image handles.
 * \param image_from  The image handle of the image to transition from.
 * \param image_to The image handle of the image to transition to.
 * \param frames The number of frame to take over the course of the transisiton.
 * \param cur_fb_index  The initial index of the current frame in the frame_buffer .
 * \return The final index of the current frame in the frame_buffer .
 */
unsigned transition_wipe(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index);

/** \brief Transition effect: A -> B as a slide, i.e. B slides over A from the right.
 *
 * \param server The channel from the client application to the display_controller.
 * \param frame_buffer An array of the frame buffer image handles.
 * \param image_from  The image handle of the image to transition from.
 * \param image_to The image handle of the image to transition to.
 * \param frames The number of frame to take over the course of the transisiton.
 * \param cur_fb_index  The initial index of the current frame in the frame_buffer .
 * \return The final index of the current frame in the frame_buffer .
 */
unsigned transition_slide(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index);

/** \brief Transition effect: A -> B as a roll, i.e. B rolls on from the right and A rolls
 * off to the right.
 *
 * \param server The channel from the client application to the display_controller.
 * \param frame_buffer An array of the frame buffer image handles.
 * \param image_from  The image handle of the image to transition from.
 * \param image_to The image handle of the image to transition to.
 * \param frames The number of frame to take over the course of the transisiton.
 * \param cur_fb_index  The initial index of the current frame in the frame_buffer .
 * \return The final index of the current frame in the frame_buffer .
 */
unsigned transition_roll(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index);

/** \brief Transition effect: A -> B as a dither, i.e. B is revealed in 2 pixel chunks
 * until A is gone.
 *
 * \param server The channel from the client application to the display_controller.
 * \param frame_buffer An array of the frame buffer image handles.
 * \param image_from  The image handle of the image to transition from.
 * \param image_to The image handle of the image to transition to.
 * \param frames The number of frame to take over the course of the transisiton.
 * \param cur_fb_index  The initial index of the current frame in the frame_buffer .
 * \return The final index of the current frame in the frame_buffer .
 */
unsigned transition_dither(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index);

/** \brief Transition effect: A -> B as a fade, i.e. A fades away as B fades in.
 *
 * \param server The channel from the client application to the display_controller.
 * \param frame_buffer An array of the frame buffer image handles.
 * \param image_from  The image handle of the image to transition from.
 * \param image_to The image handle of the image to transition to.
 * \param frames The number of frame to take over the course of the transisiton.
 * \param cur_fb_index  The initial index of the current frame in the frame_buffer .
 * \return The final index of the current frame in the frame_buffer .
 */
unsigned transition_alpha_blend(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index);

#endif /* TRANSITIONS_H_ */
