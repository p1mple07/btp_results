module sipo_top#(parameter DATA_WIDTH = 16, 
                 parameter SHIFT_DIRECTION = 1, 
                 parameter CRC_WIDTH = DATA_WIDTH/2,
                 parameter POLY = 8'b10101010)
(
    input clk,                                   // Clock input
    input reset_n,                               // Active low synchronous reset
    input sin,                                     // Serial input to SIPO
    input shift_en,                               // Shift enable signal
    output done,                                  // Done signal indicating completion of shift
    output [DATA_WIDTH-1:0] parallel_out,        // Parallel output
    input [CRC_WIDTH-1:0] received_crc,           // Received CRC
    output [CRC_WIDTH-1:0] crc_out,              // CRC output
    output error_detected,                        // Error detected flag
    output error_corrected,                       // Error corrected flag
    output crc_error                             // CRC error flag
    output [CODE_WIDTH-1:0] data_out,              // Corrected output
    output [CODE_WIDTH-1:0] encoded,              // Encoded output
    output error_corrected                       // Error corrected  flag
);

wire [DATA_WIDTH-1:0] parallel_out;
wire [CRC_WIDTH-1:0] received_crc;
wire [CRC_WIDTH-1:0] crc_out;
wire [CRC_WIDTH-1:0] crc_error;

// Connect SIPO output to CRC generator input
wire [DATA_WIDTH-1:0] parallel_out  to crc_generator.data_in;

// CRC generator
crc_generator #(.CRC_WIDTH(CRC_WIDTH), .POLY(POLY))
    uut (
        .clk(clk),
        .rst(reset_n),
        .data_in(parallel_out),
        .received(received_crc),
        .data_out(crc_out),
        .encoded(encoded),
        .syndrome(syndrome),
        .error_corrected(error_corrected),
        .error_detected(error_detected),
        .crc_error(crc_error)
    );

// One bit ECC
onebit_ecc#(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH))
  uut_sipo (
      .clk(clk),
      .reset_n(reset_n),
      .sin(sin),
      .shift_en(shift_en),
      .done(done),
      .parallel_out(parallel_out),
      .encoded(encoded),
      .received(received),
      .data_out(data_out),
      .error_detected(error_detected),
      .error_corrected(error_corrected)
      );

endmodule