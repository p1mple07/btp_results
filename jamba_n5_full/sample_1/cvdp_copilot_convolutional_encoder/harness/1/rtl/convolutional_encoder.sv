module convolutional_encoder (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    reg [1:0] prev_bits;

    always @(posedge clk or negedge rst) begin
        if (rst)
            prev_bits <= {1'b0, 1'b0};
        else
            prev_bits <= prev_bits >> 1;
            prev_bits[1] = data_in;
    end

    assign encoded_bit1 = data_in ^ prev_bits[0];
    assign encoded_bit2 = data_in ^ prev_bits[1];

endmodule
