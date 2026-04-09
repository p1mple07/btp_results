module binary_to_one_hot_decoder #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input [BINARY_WIDTH-1:0] binary_in,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

    always @* begin
        integer idx;
        for (idx = 0; idx < BINARY_WIDTH; idx = idx + 1) begin
            if (binary_in[idx] == 1'b1)
                one_hot_out[idx] = 1'b1;
            else
                one_hot_out[idx] = 1'b0;
        end
    end

    // Out-of-range handling
    always @* begin
        if (binary_in >= 2**BINARY_WIDTH - 1)
            one_hot_out = 32'b0; // Set all bits to 0
    end

endmodule
