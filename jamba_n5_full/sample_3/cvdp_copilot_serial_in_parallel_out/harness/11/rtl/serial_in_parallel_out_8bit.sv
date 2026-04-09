module sipo_top (
    input wire clk,
    input wire rst_n,
    input wire serial_in,
    input shift_en,
    output reg done,
    output reg [7:0] data_out,
    output reg [7:0] encoded,
    output reg [7:0] error_detected,
    output reg [7:0] error_corrected
);

-- SIPO block for serial‑to‑parallel conversion
instantiat serial_in_parallel_out_8bit u0 (.clk(clk), .rst(rst_n), .sin(serial_in), .shift_en(shift_en), .done(done), .data_out(data_out));

-- One‑bit ECC for single‑bit error detection and correction
instantiat onebit_ecc u1 (.data_in(data_out), .received(received), .data_out(encoded), .encoded(encoded), .error_detected(error_detected), .error_corrected(error_corrected));

endmodule
