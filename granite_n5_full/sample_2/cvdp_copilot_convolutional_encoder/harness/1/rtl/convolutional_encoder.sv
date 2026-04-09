module convolutional_encoder (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

reg [1:0] shift_register;
reg [1:0] encoded_bits;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        shift_register <= 2'b00;
        encoded_bits <= 2'b00;
    end else begin
        shift_register <= {data_in, shift_register[0:1]};
        
        // Calculate encoded_bit1 using g1
        encoded_bit1 <= ~shift_register[0] & shift_register[1];
        
        // Calculate encoded_bit2 using g2
        encoded_bit2 <= ~shift_register[1] & shift_register[0];
    end
end

endmodule