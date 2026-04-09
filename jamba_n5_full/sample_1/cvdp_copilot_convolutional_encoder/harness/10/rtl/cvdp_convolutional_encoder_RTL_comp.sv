module convolutional_encoder (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    reg [2:0] shift_reg;

    always @(posedge clk) begin
        if (!rst) begin
            shift_reg <= 3'b000;
        end else
        shift_reg <= {shift_reg[1:0], data_in};
    end

    assign encoded_bit1 = shift_reg[0] ^ shift_reg[1]; // g1
    assign encoded_bit2 = shift_reg[2] ^ shift_reg[3]; // g2

endmodule
