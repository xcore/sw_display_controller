
.section .cp.const4,       "acM", @progbits, 4
.align 4
burst_term:
.word 0xeeee4eec

.text
#define MAX_BUF_READ_SIZE (128)
.align 4
.globl block_write
.type  block_write, @function
block_write:

	//r0 adjusted buffer pointer
	//r1 jump amount
	//r2 resource id of dq
	//r3 resource id of ctrl
	//sp[] stop time

	stw r4, sp[0]

	ldw r4, cp[burst_term]

	//save the cp (has to be to r11)
	ldaw r11, cp[0]
	set cp, r0
	mov r0, r11

	mov r11 , r1

.align 4
	//get the stop time from the stack
	ldw r1, sp[1]
	bru r11

	#include "block_write_body.h"

	//r0	save reg for cp
	//r1	stop time
	//r2	resource id of dq
	//r3	resource id of ctrl
	//r4	burst term inst
	//r11	used as a temp
	//cp	adjusted buffer pointer

    setpt res[r3], r1
    out res[r3], r4

	mkmsk r4, 32
	out res[r2], r4

	set cp, r0

	ldw r4, sp[0]
	retsp 0
.globl block_write.nstackwords
.linkset block_write.nstackwords, 1

.align 4
.globl block_read
.type  block_read, @function
block_read:
	entsp 4

 	//r0 buffer pointer
	//r1 jump amount
	//r2 resource id of dq
	//r3 resource id of ctrl
	//sp[] stop time

	stw r4, sp[0]
	stw r5, sp[1]
	stw r6, sp[2]
	stw r7, sp[3]

	mov r7, r1

	//get the stop time from the stack
	ldw r4, sp[5]

	//save the dp
	ldaw r1, dp[0]

	//set the new dp
	set dp, r0

	ldaw r5, dp[63]
	add r5, r5, 4

	//load the burst term inst
	ldw r0, cp[burst_term]

	ldw r11, sp[6]
	setpt res[r2], r11

.align 4

	in r11, res[r2]
	bru r7

	#include "block_read_body.h"

	//r0	burst term data
	//r1	save reg for dp
	//r2	resource id of dq
	//r3	resource id of ctrl
	//r4	stop time
	//r5	precomputed buffer pointer increament
	//r6	buffered data
	//r11	used as a temp
	//dp	adjusted buffer pointer

	in r11, res[r2]
	setpt res[r3], r4

	in r4, res[r2]
	out res[r3], r0

	in r3, res[r2]
	mkmsk r0, 32

	in r7, res[r2]

	out res[r2], r0

    stw r11, dp[60]
    stw r4, dp[61]
	stw r3, dp[62]
	stw r7, dp[63]

	ldaw r11, dp[0]
	eq r5, r11, r5

	bf r5, jump
	extdp 1
	stw r6, dp[0]
jump:
	//restore the dp
	set dp, r1

	ldw r7, sp[3]
	ldw r6, sp[2]
	ldw r5, sp[1]
	ldw r4, sp[0]
	retsp 4

.globl block_read.nstackwords
.linkset block_read.nstackwords, 4

.align 4
.globl short_block_read
.type  short_block_read, @function
short_block_read:
	entsp 3

 	//r0 buffer pointer
	//r1 read amount of buffer in words
	//r2 resource id of dq
	//r3 resource id of ctrl
	//sp[4] stop time 1
	//sp[5] stop time 2

	stw r4, sp[0]
	stw r5, sp[1]
	stw r6, sp[2]


	//get the stop time from the stack
	ldw r4, sp[4]

	//load the burst term inst
	ldw r5, cp[burst_term]

	ldw r11, sp[5]
	setpt res[r2], r11

	//junk
	in r11, res[r2]

	//word 0
	in r11, res[r2]
	setpt res[r3], r4

	//word 1
	in r4, res[r2]
	out res[r3], r5

	//word 2
	in r5, res[r2]
	mkmsk r3, 32

	//word 3
	in r6, res[r2]

	out res[r2], r3

	ldc r2, 4
	sub r1, r2, r1

    bru r1
    stw r6, r0[3]
    stw r5, r0[2]
	stw r4, r0[1]
	stw r11, r0[0]

	ldw r6, sp[2]
	ldw r5, sp[1]
	ldw r4, sp[0]
	retsp 3

.globl short_block_read.nstackwords
.linkset short_block_read.nstackwords, 3

