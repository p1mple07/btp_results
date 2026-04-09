module sipo_top#(parameter DATA_WIDTH = 16, parameter SHIFT_DIRECTION = 1, parameter CRC_WIDTH = DATA_WIDTH / 2)
    (
        input clk,                                   // Clock input
        input reset_n,                               // Active low reset
        input sin,                                     // Serial input to SIPO
        input shift_en,                               // Shift enable signal
        output done,                                 // Done signal indicating completion of shift
        output [DATA_WIDTH-1:0] parallel_out,         // Parallel output
        output [CODE_WIDTH-1:0] encoded,              // Encoded output
        output [DATA_WIDTH-1:0] data_out,             // Corrected output
        output error_detected,                        // Error detected flag
        output error_corrected,                        // Error corrected flag
        input [CRC_WIDTH-1:0] received_crc             // Received CRC
        output [CRC_WIDTH-1:0] crc_out                // CRC output
        output crc_error                             // CRC error flag
    )
    (
        wire [DATA_WIDTH-1:0] parallel_out;
        wire [CODE_WIDTH-1:0] sipo_out_ecc_in;

        serial_in_parallel_out_8bit  #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) uut_serial_in_parallel_out_8bit (
            .clk(clk),               // Clock input
            .reset_n(reset_n),       // Active low reset
            .sin(sin),               // Serial input to SIPO
            .shift_en(shift_en),      // Shift enable signal
            .done(done),              // Done signal from SIPO
            .parallel_out(parallel_out) // Parallel output from SIPO
        );

        // CRC Generator
        onebit_ecc#(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH), .CRC_WIDTH(CRC_WIDTH)) uut_crc_generator (
            .data_in(parallel_out),
            .encoded(encoded),
            .received(received_crc),
            .data_out(data_out),
            .error_detected(error_detected),
            .error_corrected(error_corrected),
            .crc_out(crc_out),
            .crc_error(crc_error)
        );
    endmodule