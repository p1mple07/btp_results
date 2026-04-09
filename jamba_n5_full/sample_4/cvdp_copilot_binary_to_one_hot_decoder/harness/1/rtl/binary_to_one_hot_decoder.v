module binary_to_one_hot_decoder (
    input wire [BINARY_WIDTH-1:0] binary_in,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

    parameter BINARY_WIDTH = 5;
    parameter OUTPUT_WIDTH = 32;

    always @(*) begin
        one_hot_out <= 1'b0;
        for (integer i = 0; i < OUTPUT_WIDTH; i++) begin
            if (binary_in == i) begin
                one_hot_out[i] = 1'b1;
                break;
            end
        end
    end

endmodule
