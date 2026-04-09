module bcd_to_excess_3(
    input  logic [3:0] bcd,
    output logic [3:0] excess3,
    output logic       error
);

    // Combinational logic for BCD to Excess-3 conversion
    always_comb begin
        // Check if the BCD input is valid (0 to 9)
        if (bcd >= 4'd0 && bcd <= 4'd9) begin
            excess3 = bcd + 4'd3; // Excess-3 code is BCD + 3
            error   = 1'b0;
        end else begin
            excess3 = 4'd0; // Default output for invalid input
            error   = 1'b1; // Assert error flag for invalid input
        end
    end

endmodule