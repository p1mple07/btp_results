module convolutional_encoder #(
    parameter WIDTH = 2
) (
    input clk,
    input rst,
    input data_in,
    output reg [1:0] encoded_bit1,
    output reg [1:0] encoded_bit2
);

reg [WIDTH-1:0] shift_reg;

always @(posedge clk) begin
    if (!rst) begin
        shift_reg <= 2'b00;
    end else begin
        shift_reg <= {shift_reg[WIDTH-2:0], data_in};
    end
end

assign encoded_bit1 = shift_reg[1] ^ shift_reg[0];
assign encoded_bit2 = shift_reg[0] ^ shift_reg[1];

endmodule
