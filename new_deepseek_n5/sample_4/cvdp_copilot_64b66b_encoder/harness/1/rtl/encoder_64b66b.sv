module rtl/encoder_64b66b(
    input clock_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output [65:0] encoder_data_out
);

    // Reset case
    if (rst_in) begin
        encoder_data_out = 66'h0;
        return;
    end

    // Pure data case
    if (encoder_control_in == 8'h00000000) begin
        encoder_data_out = {2'b01, encoder_data_in};
        return;
    end

    // Control case
    encoder_data_out = {2'b10, 64'h0};
    return;
endmodule