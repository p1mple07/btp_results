module convolutional_encoder(
    input clk,
    input rst,
    input data_in,
    output encoded_bit1,
    output encoded_bit2
);

reg [2:0] shift_register;

always_ff @(posedge clk or negedge rst) begin
    if (rst)
        shift_register <= {3'b000};
    else
        shift_register <= {shift_register[1:0], data_in};
end

assign encoded_bit1 = data_in ^ shift_register[1];
assign encoded_bit2 = data_in ^ shift_register[0];

endmodule
