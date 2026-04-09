module serial_in_parallel_out_8bit (
    input clk,
    input rst,
    input serial_in,
    input shift_en,
    output reg [7:0] parallel_out,
    output done,
    output encoded,
    output error_detected,
    output error_corrected
);

parameter WIDTH = 16;

// SIPO interface
interface sipo #(.WIDTH(WIDTH));
    input clk,
    input rst,
    input sin,
    input shift_en;
    output reg [WIDTH-1:0] out;
endinterface

// ECC interface
interface onebit_ecc #(.DATA_WIDTH(WIDTH), .CODE_WIDTH(WIDTH + CLOG2(WIDTH) + 1));
    input data_in,
    output data_out,
    output encoded,
    output error_detected,
    output error_corrected;
endinterface

// Instantiate the SIPO
sipo #(.WIDTH(WIDTH)) sipo (
    .clk(clk),
    .rst(rst),
    .sin(serial_in),
    .shift_en(shift_en),
    .out(parallel_out)
);

// Instantiate the ECC
onebit_ecc ecc (
    .data_in(sipo.out),
    .received(serial_in),
    .data_out(data_out),
    .encoded(encoded),
    .error_detected(error_detected),
    .error_corrected(error_corrected)
);

endmodule
