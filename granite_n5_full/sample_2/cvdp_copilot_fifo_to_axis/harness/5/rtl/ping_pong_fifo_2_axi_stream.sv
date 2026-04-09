module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 32
)(
    // Inputs
    input  logic i_flush,
    input  logic i_pause,
    input  logic i_block_fifo_rdy,
    input  logic [23:0] i_block_fifo_size,
    input  logic [DATA_WIDTH-1:0] i_block_fifo_data,
    input  logic [3:0] i_axi_user,
    input  logic i_axi_clk,
    input  logic i_axi_ready,
    // Outputs
    output logic o_axi_user,
    output logic o_axi_valid,
    output logic o_axi_last,
    output logic o_block_fifo_act,
    output logic o_block_fifo_stb,
    output logic o_block_fifo_data
);

// Verilog code implementation goes here

endmodule

/*
 * Copyright (C) 2019 Intel Corporation.
 */
 /*
 * MIT License
 * Copyright (C) 2018 Intel Corporation.
 */

/**
 * @file ping_pong_fifo_2_axi_stream.vhdl
 * @author Intel Corporation.
 * @date 01/01/01 (1.01)
 * @version 0.1.01
 */
library verilog

import "verilog/ Ping Pong Fifo (FIFO).
 *
 * @note:
 *  - The FIFO.vhd
 *  - The FIFO module should be imported at the top level.
 *  - The FIFO module should contain all the input ports and all the output ports of the FIFO module.
 *  - - Verify the code.
    // */
    // FIFO module.
    // FIFO module.
    // 1. FIFO module.
    // 2. FIFO module.
    import "fifo.v"

endmodule