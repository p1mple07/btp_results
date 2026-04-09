module sipo_top#(parameter DATA_WIDTH = 16, parameter SHIFT_DIRECTION = 1, parameter CRC_WIDTH = DATA_WIDTH / 2) (
    input clk, 
    input reset_n, 
    input sin, 
    input shift_en, 
    output done, 
    output [DATA_WIDTH-1:0] parallel_out, 
    input [CRC_WIDTH-1:0] received_crc
    );
    
    wire [DATA_WIDTH-1:0] parallel_out;
    wire [CODE_WIDTH-1:0] sipo_out_ecc_in;
    
    serial_in_parallel_out_8bit  #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) uut_serial_in_parallel_out_8bit  (
        .clk(clk),               // Clock input
        .reset_n(reset_n),       // Reset input
        .sin(sin),               // Serial input to SIPO
        .shift_en(shift_en),      // Shift enable signal
        .done(done),             // Done signal from SIPO
        .parallel_out(parallel_out) // Parallel output from SIPO
    );
 
    //crc generator
    crc_generator  #(.DATA_WIDTH(DATA_WIDTH), .CRC_WIDTH(CRC_WIDTH), .POLY(8'b10101010)) uut_crc_generator (
        .data_in(parallel_out),
        .clk(clk),
        .rst(reset_n),
        .crc_out(crc_out),
        .crc_error(crc_error)
        );
 
    //onebit ecc
    onebit_ecc#(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH)) uut_onebit_ecc1 (
        .data_in(parallel_out),
        .encoded(encoded),
        .received(received_crc),
        .data_out(data_out),
        .error_detected(error_detected),
        .error_corrected(error_corrected)
        );
 
    endmodule