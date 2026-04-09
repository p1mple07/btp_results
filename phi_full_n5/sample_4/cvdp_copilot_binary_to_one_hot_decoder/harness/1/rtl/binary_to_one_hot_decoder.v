module binary_to_one_hot_decoder #(parameter BINARY_WIDTH = 5, parameter OUTPUT_WIDTH = 32)
(
    input [BINARY_WIDTH-1:0] binary_in,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

    integer index;

    always @* begin
        if (binary_in < 2**BINARY_WIDTH) begin
            for (index = 0; index < OUTPUT_WIDTH; index = index + 1) begin
                if (binary_in == index)
                    one_hot_out[index] = 1'b1;
                else
                    one_hot_out[index] = 1'b0;
            end
        end else if (binary_in >= OUTPUT_WIDTH) begin
            one_hot_out = 32'b0;
        end
    end

endmodule
