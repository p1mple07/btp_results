module sipo_top#(
    parameter DATA_WIDTH = 16,
    parameter SHIFT_DIRECTION = 1,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)
) (
    input clk,
    input reset_n,
    input serial_in,
    input shift_en,
    output reg done,
    output [DATA_WIDTH-1:0] data_out,
    output [CODE_WIDTH-1:0] encoded,
    output error_detected,
    output error_corrected
);

    // --- Serial-to-Parallel Convertor ---------------------------------------
    serial_in_parallel_out_8bit #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION))
        uut_sipo (
            .clk(clk),
            .reset_n(reset_n),
            .sin(serial_in),
            .shift_en(shift_en),
            .done(done),
            .parallel_out(crc_out)
        );

    // --- One‑Bit Error Correction -----------------------------------------
    onebit_ecc #(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH))
        uut_onebit_ecc1 (
            .data_in(parallel_out),
            .encoded(encoded),
            .received(received),
            .data_out(data_out),
            .error_detected(error_detected),
            .error_corrected(error_corrected)
        );

    // --- CRC Generation -------------------------------------------------
    crc_generator #(
        .DATA_WIDTH(DATA_WIDTH),
        .POLY(8'b10101010),
        .CRC_WIDTH(DATA_WIDTH/2)
    ) uut_crc_generator (
        .clk(clk),
        .rst(reset_n),
        .sin(serial_in),
        .shift_en(shift_en),
        .done(done),
        .parallel_out(crc_out)
    );

    // Connect CRC output to the desired signal
    assign crc_out_signal = crc_out;

endmodule
