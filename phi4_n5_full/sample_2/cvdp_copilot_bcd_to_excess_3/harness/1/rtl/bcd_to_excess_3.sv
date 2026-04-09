module bcd_to_excess_3(
    input  logic [3:0] bcd,    // 4-bit BCD input (0 to 9 valid)
    output logic [3:0] excess3, // 4-bit Excess-3 output
    output logic        error   // Error flag (1 when input is invalid)
);

    // Combinationally compute the output based on the BCD input.
    // For valid BCD (0 to 9), excess3 = bcd + 3.
    // For invalid BCD (10 to 15), excess3 is set to 0 and error is asserted.
    always_comb begin
        if (bcd >= 10) begin
            excess3 = 4'd0;
            error   = 1'b1;
        end else begin
            excess3 = bcd + 4'd3;
            error   = 1'b0;
        end
    end

endmodule