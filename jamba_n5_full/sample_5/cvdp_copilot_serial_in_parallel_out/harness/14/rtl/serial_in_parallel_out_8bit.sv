module sipo_top#(
    parameter DATA_WIDTH = 16,
    parameter SHIFT_DIRECTION = 1,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)
) (
    input clk,
    input reset_n,
    input serial_in,
    input shift_en,
    input [CODE_WIDTH-1:0] received,
    output done,
    output [DATA_WIDTH-1:0] data_out,
    output [CODE_WIDTH-1:0] encoded,
    output error_detected,
    output error_corrected,
    output [DATA_WIDTH-1:0] parallel_out,
    output reg crc_out,
    output reg crc_error
);

    wire [DATA_WIDTH-1:0] parallel_out;
    wire [DATA_WIDTH-1:0] sipo_out_ecc_in;

    serial_in_parallel_out_8bit #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) uut_sipo (
        .clk           (clk),
        .reset_n       (reset_n),
        .sin           (serial_in),
        .shift_en      (shift_en),
        .done          (done),
        .parallel_out  (parallel_out)
    );

    // Connect the parallel output to the CRC generator
    assign sipo_out_ecc_in = parallel_out;

    // Instantiate the CRC generator
    crc_generator #(.DATA_WIDTH(DATA_WIDTH), .CLCK(clk), .RST(reset_n)) uut_crc (
        .data_in(sipo_out_ecc_in),
        .clk(clk),
        .rst(reset_n),
        .crc_out(crc_out),
        .error_detected(crc_error)
    );

    // Connect the CRC output and error to the top‑level outputs
    assign data_in = sipo_out_ecc_in;
    assign error_corrected = crc_error;
    assign crc_out = uut_crc.crc_out;

    onebit_ecc uut_onebit_ecc1 (
        .data_in(received),
        .encoded(encoded),
        .received(received),
        .data_out(data_out),
        .error_detected(error_detected),
        .error_corrected(error_corrected)
    );

endmodule
