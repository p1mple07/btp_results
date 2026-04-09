module sripo_top (
    input wire clk,
    input wire rst,
    input wire serial_in,
    input shift_en,
    input serial_in_bit,
    input clk_1bit,
    input rst_n,
    output reg done,
    output data_out,
    output encoded,
    output error_detected,
    output error_corrected
);

    // Define the onebit_ecc module here
    onebit_ecc u_onebit_ecc (
        .data_in(serial_in_bit),
        .received(received_parity),
        .shift_en(shift_en),
        .clk(clk),
        .rst(rst_n),
        .data_out(corrected_data),
        .encoded(encoded_data),
        .error_detected(error_detect),
        .error_corrected(corrected_error)
    );

    // Connect outputs
    assign done = u_onebit_ecc.done;
    assign data_out = u_onebit_ecc.data_out;
    assign encoded = u_onebit_ecc.encoded;
    assign error_detected = u_onebit_ecc.error_detected;
    assign error_corrected = u_onebit_ecc.error_corrected;

    // The rest of the SIPO code remains
    always @(posedge clk) begin
        if (shift_en) begin
            parallel_out[7:1] <= parallel_out[6:0];
            parallel_out[0] <= serial_in;
        end
    end

endmodule
