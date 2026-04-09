module binary_to_one_hot_decoder #(parameter BINARY_WIDTH = 5, parameter OUTPUT_WIDTH = 32)
(
    input [BINARY_WIDTH-1:0] binary_in,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

    integer i;

    always @ (binary_in) begin
        one_hot_out = 0;
        for (i = 0; i < OUTPUT_WIDTH; i++) begin
            if (i == binary_in)
                one_hot_out = one_hot_out | (1 << i);
        end
    end

endmodule
