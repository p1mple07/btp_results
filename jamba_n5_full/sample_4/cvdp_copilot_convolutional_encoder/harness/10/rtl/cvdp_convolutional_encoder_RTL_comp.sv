module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );

    reg [2:0] shift_reg;
    reg new_state;

    initial begin
        shift_reg = 3'b000;
    end

    always @(posedge clk) begin
        if (rst)
            shift_reg <= 3'b000;
        else
            shift_reg <= {shift_reg[2:0], data_in};
    end

    assign encoded_bit1 = shift_reg[2];
    assign encoded_bit2 = shift_reg[1];

endmodule
