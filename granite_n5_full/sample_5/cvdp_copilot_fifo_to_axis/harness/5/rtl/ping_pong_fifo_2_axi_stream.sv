// This file contains the code necessary for the given RTL module.

module ping_pong_fifo_2_axi_stream(
    input bit i_flush,
    input bit i_pause,
    input bit i_block_fifo_rdy,
    input int unsigned i_block_fifo_size,
    input logic [DATA_WIDTH-1:0] i_block_fifo_data,
    input logic [3:0] i_axi_user,
    input logic i_axi_ready,
    output bit o_block_fifo_act,
    output bit o_block_fifo_stb,
    output bit o_axi_valid,
    output bit [DATA_WIDTH-1:0] o_axi_data,
    output bit [3:0] o_axi_user,
    output bit o_axi_last
);

//
// This is the first line of the generated code.

/*
 * Project Name: 
 * Module Name: 
 * Engineer: 
 */

/*
 * File Name: 
 * File Location: 
 */

/*
 * Module Description:
 *
 * Module Implementation:
 *
 * Assumptions:
 *
 * Input Port List:
 *
 * Output Port List:
 *
 * Local Functions:
 *
 * Task Dependencies:
 *
 * Testbench Files:
 *
 * Compile Time Options:
 *
 * Simulink Coder Documentation:
 *
 *
 * Other Notes:
 *
 */

// Implement the RTL module.
// For example, if the RTL module has three major files (such as "top.sv" and "bottom.sv".

`timescale
1 second per 1 second
   
`include <stdlib.vhd>

`default_clock.vhd

`include <iostream.h>

`include <string.h>

`include <stdio.h>

`include <stdbool.h>

`include <verilog.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>.

`include <list.h>

`include <list.h>

`include <list.h>

`include <stdlib.h>

`include <iostream.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <stdlib.h>

`include <stdlib.h>

`include <stdlib.h>

`include <stdlib.h>

`include <list.h>

`include <list.h>

`include <list.h>.

`include <stdlib.h>

`include <verilog.h>

`include <stdio.h>

`include <iostream.h>

`include <list.h>.

`include <list.h>

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>.

`include <list.h>

`include <list.h>

`include <list.h>.

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>

`include <list.h>