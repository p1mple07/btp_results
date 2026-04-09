module convolutional_encoder (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    reg [3:0] state;

    initial begin
        state = 3'b0;
    end

    always @(posedge clk) begin
        if (rst)
            state <= 3'b0;
        else
            state = state << 1;
            state = state ^ 'b111;  // g1
            state = state ^ 'b101;  // g2
    end

    assign encoded_bit1 = state[0] ^ 'b0;
    assign encoded_bit2 = state[1] ^ 'b0;

endmodule
