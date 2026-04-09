module bcd_to_excess_3 (
    input  logic [3:0] bcd,
    output logic [3:0] excess3,
    output logic       error
);

    // Combinational logic for BCD to Excess-3 conversion
    always_comb begin
        if (bcd > 9) begin
            // Invalid BCD input: values 10 to 15
            error   = 1;
            excess3 = 4'b0000;
        end else begin
            // Valid BCD input: 0 to 9
            error    = 0;
            excess3  = bcd + 4'd3;
        end
    end

endmodule