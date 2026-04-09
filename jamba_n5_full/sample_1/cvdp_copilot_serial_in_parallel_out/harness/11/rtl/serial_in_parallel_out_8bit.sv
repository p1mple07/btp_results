module sipo_top (
    input wire clk,
    input wire rst,
    input wire serial_in,
    input wire shift_en,
    input wire received,
    input wire [7:0] shift_en_input,
    // maybe we don't need shift_en_input but the example uses shift_en
    output wire done,
    output wire data_out,
    output wire encoded,
    output wire error_detected,
    output wire error_corrected
);

// Instantiate the serial in parallel out module
instantiation #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(1)) inst_sipo (
    .clk(clk),
    .rst(rst),
    .sin(serial_in),
    .shift_en(shift_en),
    .done(done_sipo),
    .data_out(data_out_sipo),
    .parallel_out(parallel_out_sipo)
);

// Instantiate the onebit_ecc module
instanciation #(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(DATA_WIDTH + clog2(DATA_WIDTH + 1))) inst_onebit (
    .data_in(serial_in),
    .received(received),
    .data_out(encoded),
    .encoded(encoded),
    .error_detected(error_detected),
    .error_corrected(error_corrected)
);

// Generate the outputs
assign done = done_sipo;
assign data_out = data_out_sipo;
assign encoded = encoded_sipo;
assign error_detected = error_detected_sipo;
assign error_corrected = error_corrected_sipo;

endmodule
