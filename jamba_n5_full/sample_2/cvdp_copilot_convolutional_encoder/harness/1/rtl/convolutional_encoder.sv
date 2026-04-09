module convolutional_encoder (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    reg [1:0] state;

    always @(posedge clk) begin
        if (~rst)
            state <= 2'b0;
        else
            state <= state << 1;
    end

    assign encoded_bit1 = data_in xor state[0] xor state[1];
    assign encoded_bit2 = data_in xor state[1] xor state[0];

endmodule
