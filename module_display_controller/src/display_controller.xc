#include "display_controller.h"
#include "lcd.h"
#include "sdram.h"
#include <stdio.h>

#define MAX_WIDTH 400

/*
 * Notes
 * - only support lcd size images
 * - number of images is fixed at compile time by a param
 * - no buffer_over run checks are performed on read/write operations
 * - uses a double line buffer to the lcd
 * - a client can lock out the low priority channel between the dc and sdram -> thus meaning that fb changes cannot happen. but the lcd will keep working
 */

////////////////////////////////////////////////////////////////////////////////////////////

#pragma unsafe arrays
void display_controller_read(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned * movable buffer,
        unsigned image_no,
        unsigned line,
        unsigned word_count,
        unsigned word_offset) {
    s_command c;
    c.type = CMD_READ;
    c.image_no = image_no;
    c.line = line;
    c.word_count = word_count;
    c.word_offset = word_offset;
    from_dc.push(c, move(buffer));
}

#pragma unsafe arrays
void display_controller_write(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned * movable buffer,
        unsigned image_no,
        unsigned line,
        unsigned word_count,
        unsigned word_offset) {
    s_command c;
    c.type = CMD_WRITE;
    c.image_no = image_no;
    c.line = line;
    c.word_count = word_count;
    c.word_offset = word_offset;
    from_dc.push(c, move(buffer));
}

#pragma unsafe arrays
void display_controller_frame_buffer_commit(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned image_no) {
    s_command c;
    c.type = CMD_SET_FRAME;
    c.image_no = image_no;
    from_dc.push(c, null);
}

////////////////////////////////////////////////////////////////////////////////////////////

#pragma unsafe arrays
[[distributable]]
void command_buffer(server interface app_to_cmd_buffer_i  a,
        server interface cmd_buffer_to_dc_i b) {
#if 1
#define SIZE 1
    unsigned head = 0;
    unsigned fill = 0;
    s_command cmd_buffer[SIZE];
    unsigned * movable cmd_pointer_buffer[SIZE];

    a.ready();
    while(1){
        select {
            case a.push(s_command c, unsigned * movable p) : {

                unsigned index = head % SIZE;
                cmd_buffer[index] = c;
                cmd_pointer_buffer[index] = move(p);
                head++;
                fill++;
                b.ready();
                if(fill < SIZE)
                    a.ready();
                break;
            }
            case b.pop() -> {s_command c, unsigned * movable p}: {
                unsigned index = (head-fill) % SIZE;
                p = move(cmd_pointer_buffer[index]);
                c = cmd_buffer[index];
                fill--;
                if(fill)
                    b.ready();
                if(fill == (SIZE-1))
                    a.ready();
                break;
            }
        }
    }
#else
    s_command cmd_buffer_entry;
    unsigned * movable cmd_pointer_buffer_entry;
    int occupied = 0;
    a.ready();
    while (1) {
        select {
            case !occupied => a.push(s_command c, unsigned * movable p):
                cmd_pointer_buffer_entry = move(p);
                cmd_buffer_entry = c;
                b.ready();
                occupied = 1;
            break;
            case occupied => rx.pop() -> {s_command c, unsigned * movable p}:
                p = move(cmd_pointer_buffer_entry);
                c = cmd_buffer_entry;
                a.ready();
                occupied = 0;
            break;
        }
    }
#endif
}

#pragma unsafe arrays
[[distributable]]
void response_buffer(server interface dc_to_res_buf_i  tx,
        server interface res_buf_to_app_i rx) {
    unsigned * movable entry;
    unsigned return_val;
    int occupied = 0;
    tx.ready();
    while (1) {
        select {
            case !occupied => tx.push(unsigned * movable p, unsigned r):
                entry = move(p);
                return_val = r;
                rx.ready();
                occupied = 1;
            break;
            case occupied => rx.pop() -> {unsigned * movable p, unsigned r}:
                p = move(entry);
                r = return_val;
                tx.ready();
                occupied = 0;
            break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////

#define NONE (-1)

typedef struct  {
  unsigned height;
  unsigned words_per_line;

  unsigned index;

  unsigned current_fb_image_index;
  unsigned current_fb_image_line;
  unsigned next_fb_image_index;
  unsigned sdram_cmd_buffer_fill;

} dc_state ;

#pragma unsafe arrays
static void client_command(
        s_command &cmd,
        unsigned * movable buffer_pointer,
        streaming chanend c_sdram_client, s_sdram_state &sdram_state_client,
        dc_state &s,
        unsigned image_base_address[]
) {

    switch (cmd.type) {

        case CMD_READ: {
            unsigned address = image_base_address[cmd.image_no] + cmd.line*s.words_per_line + cmd.word_offset;
            sdram_read(c_sdram_client, sdram_state_client, address, cmd.word_count, move(buffer_pointer));
            s.sdram_cmd_buffer_fill++;
            break;
        }

        case CMD_WRITE:{
            //reject if image_no is the current frame
            unsigned address = image_base_address[cmd.image_no] + cmd.line*s.words_per_line + cmd.word_offset;
            sdram_write(c_sdram_client, sdram_state_client, address, cmd.word_count, move(buffer_pointer));
            s.sdram_cmd_buffer_fill++;


            break;
        }

        case CMD_SET_FRAME: {
            //if image_no is pending the save this request and dont allow any more

            s.next_fb_image_index = cmd.image_no;
            break;
        }
        default: {
            __builtin_unreachable();
            break;
        }
    }
    return;
}

#pragma unsafe arrays
static void next_lcd_line(
        streaming chanend c_lcd,
        streaming chanend c_sdram_lcd,
        s_sdram_state &sdram_state_lcd,
        server interface dc_vsync_interface_i vsync,
        dc_state &s,
        unsigned * movable lcd_line_buffer_pointer[3],
        unsigned image_base_address[]
) {
    sdram_complete(c_sdram_lcd, sdram_state_lcd, lcd_line_buffer_pointer[s.index]);
    unsafe {
        lcd_update(c_lcd, lcd_line_buffer_pointer[s.index]);
    }
    s.index = (s.index+1);
    if(s.index == 3)
        s.index = 0;

    s.current_fb_image_line++;

    if (s.current_fb_image_line == s.height) {
        vsync.update();
        s.current_fb_image_line = 0;
        if (s.next_fb_image_index != NONE) {
            s.current_fb_image_index = s.next_fb_image_index;
            s.next_fb_image_index = NONE;
        }
    }
    unsigned next_line_address = (s.current_fb_image_line * s.words_per_line)
                                + image_base_address[s.current_fb_image_index];
    sdram_read (c_sdram_lcd, sdram_state_lcd, next_line_address, s.words_per_line,
           move(lcd_line_buffer_pointer[s.index]));

}

#pragma unsafe arrays
void display_controller(
        client interface cmd_buffer_to_dc_i to_dc,
        client interface dc_to_res_buf_i from_dc,
        server interface dc_vsync_interface_i vsync,
        static const unsigned n,
        static const unsigned height,
        static const unsigned width,
        static const unsigned bytes_per_pixel,
        client interface memory_address_allocator_i mem_alloc,
        streaming chanend c_sdram_lcd,
        streaming chanend c_sdram_client,
        streaming chanend c_lcd) {

    dc_state s;
    unsigned image_base_address[n];
    unsigned image_write_pending_count[n];

    for(unsigned c=0;c<n;c++)
        image_write_pending_count[c]=0;

    unsigned line_width_words = width * bytes_per_pixel / sizeof(unsigned);
    s.words_per_line = line_width_words;
    s.height = height;
    s.next_fb_image_index = NONE;
    unsigned lcd_line_buffer_0[MAX_WIDTH];
    unsigned lcd_line_buffer_1[MAX_WIDTH];
    unsigned lcd_line_buffer_2[MAX_WIDTH];

    unsigned * movable lcd_line_buffer_pointer[3] = {lcd_line_buffer_0, lcd_line_buffer_1, lcd_line_buffer_2};

    s_sdram_state sdram_state_lcd;
    sdram_init_state(c_sdram_lcd, sdram_state_lcd);
    s_sdram_state sdram_state_client;
    sdram_init_state(c_sdram_client, sdram_state_client);

    unsigned required_words = 0;

    for(unsigned c = 0; c < n; c++){
        unsigned w = line_width_words*height;
        image_base_address[c] = required_words;
        required_words += w;
    }

    unsigned base_address;
    if(mem_alloc.request(required_words*sizeof(unsigned), base_address)){
        //TODO error
        return;
    }

    for(unsigned c = 0; c < n; c++)
        image_base_address[c] += base_address;

    //Initialise the 0 frame buffer
    for(unsigned w=0;w<line_width_words;w++)
        lcd_line_buffer_pointer[0][w] = 0x0000000;

    s.current_fb_image_index = 0;
    for(unsigned l=0; l<height; l++){
        unsigned address = image_base_address[0] + (l*s.words_per_line);
        sdram_write(c_sdram_lcd, sdram_state_lcd, address, s.words_per_line,
                move(lcd_line_buffer_pointer[0]));
        sdram_complete(c_sdram_lcd, sdram_state_lcd, lcd_line_buffer_pointer[0]);
    }

    //now initialise the lcd
    sdram_read (c_sdram_lcd, sdram_state_lcd, image_base_address[0],
            s.words_per_line, move(lcd_line_buffer_pointer[0]));
    sdram_complete(c_sdram_lcd, sdram_state_lcd, lcd_line_buffer_pointer[0]);

    sdram_read (c_sdram_lcd, sdram_state_lcd, image_base_address[0] + s.words_per_line,
            s.words_per_line, move(lcd_line_buffer_pointer[1]));
    sdram_complete(c_sdram_lcd, sdram_state_lcd, lcd_line_buffer_pointer[1]);

    sdram_read (c_sdram_lcd, sdram_state_lcd, image_base_address[0] + s.words_per_line,
            s.words_per_line, move(lcd_line_buffer_pointer[2]));
    unsafe {
        lcd_init(c_lcd, lcd_line_buffer_pointer[0]);
        lcd_update(c_lcd, lcd_line_buffer_pointer[1]);
    }
    s.index = 2;
    s.current_fb_image_line = 2;
    s.sdram_cmd_buffer_fill = 0;
    // Used for the SDRAM accesses by the application

    unsigned complete_counter = 0;
    unsigned issued_counter = 0;

    unsigned * movable  buffer_pointer;
    while (1) {
        #pragma ordered
        select {
            case lcd_req(c_lcd): {
                next_lcd_line(c_lcd, c_sdram_lcd, sdram_state_lcd, vsync, s, lcd_line_buffer_pointer, image_base_address);
                break;
            }

            case vsync.vsync() -> unsigned r:{
                r = s.current_fb_image_index;
                break;
            }

            case sdram_complete(c_sdram_client, sdram_state_client, buffer_pointer) : {
                from_dc.push(move(buffer_pointer), CMD_SUCCESS);
                s.sdram_cmd_buffer_fill--;
                complete_counter++;
                //if there was a pending set_frame on this write then apply it.

                break;
            }
            case (s.sdram_cmd_buffer_fill < SDRAM_MAX_CMD_BUFFER) => to_dc.ready(): {
                s_command cmd;
                {cmd, buffer_pointer} = to_dc.pop();

                //a set frame must not complete whilst there are any writes to its image_no issued to the sdram


                //bounds checking on image number
                if(cmd.type == CMD_SET_FRAME){
                    if(cmd.image_no >= n){
                        //out of bounds
                        break;
                    }
                } else {
                    if(cmd.image_no >= n){
                        from_dc.push(move(buffer_pointer), CMD_OUT_OF_RANGE);
                        break;
                    }

                    if(cmd.image_no == s.current_fb_image_index && cmd.type == CMD_WRITE){
                        //trying to modify current fb
                        from_dc.push(move(buffer_pointer), CMD_MODIFY_CURRENT_FB);
                        break;
                    }
                    issued_counter++;
                }
                client_command(cmd, move(buffer_pointer),
                        c_sdram_client, sdram_state_client, s, image_base_address);
                break;
            }

        }
    }
}
