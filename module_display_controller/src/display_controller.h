#ifndef _display_controller_h_
#define _display_controller_h_

#include "memory_address_allocator.h"

typedef enum {
  CMD_WRITE,
  CMD_READ,
  CMD_SET_FRAME
} e_commands;

typedef enum {
    CMD_SUCCESS,
    CMD_OUT_OF_RANGE,
    CMD_MODIFY_CURRENT_FB
} e_command_return_val;

typedef struct {
    e_commands type;
    unsigned image_no;

    unsigned line;
    unsigned word_offset;
    unsigned word_count;
} s_command;

//////////////////////////////// cmd buffering ////////////////////////////////////////

interface app_to_cmd_buffer_i {
    [[notification]] slave void ready();
    [[guarded, clears_notification]] void push(s_command cmd, unsigned * movable p);
};


interface cmd_buffer_to_dc_i {
    [[notification]] slave void ready();
    [[guarded, clears_notification]] {s_command, unsigned * movable} pop();
};

[[distributable]]
void command_buffer(server interface app_to_cmd_buffer_i  tx,
                    server interface cmd_buffer_to_dc_i rx);

//////////////////////////////////response buffering //////////////////////////////////


interface dc_to_res_buf_i {
    [[notification]] slave void ready();
    [[guarded, clears_notification]] void push(unsigned * movable p, unsigned return_val);
};

interface res_buf_to_app_i {
    [[notification]] slave void ready();
    [[guarded, clears_notification]] {unsigned * movable, unsigned}  pop();
};

[[distributable]]
void response_buffer(server interface dc_to_res_buf_i  tx,
                    server interface res_buf_to_app_i rx);


////////////////////////////////////////////////////////////////////////

interface dc_vsync_interface_i {
    [[notification]] slave void update();
    [[guarded, clears_notification]] unsigned vsync();
};

////////////////////////////////////////////////////////////////////////

void display_controller_read(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned * movable buffer,
        unsigned image_no,
        unsigned line,
        unsigned word_count,
        unsigned word_offset);

void display_controller_write(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned * movable buffer,
        unsigned image_no,
        unsigned line,
        unsigned word_count,
        unsigned word_offset);

void display_controller_frame_buffer_commit(
        client interface app_to_cmd_buffer_i from_dc,
        unsigned image_no);

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
        streaming chanend c_lcd);

#endif
