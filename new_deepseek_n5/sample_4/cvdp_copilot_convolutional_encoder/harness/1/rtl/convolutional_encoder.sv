module convolutional_encoder(
    input clock,
    input rst,
    input data_in,
    output encoded_bit1,
    output encoded_bit2
);
    // Internal state variables
    reg [2:0] shift_reg;
    reg encoded_bit1, encoded_bit2;
    
    // Initialize outputs to 0
    always @* begin
        encoded_bit1 = 0;
        encoded_bit2 = 0;
    end
    
    // Reset logic
    always @ (rst or data_in) begin
        if (rst) begin
            shift_reg = 0;
            encoded_bit1 = 0;
            encoded_bit2 = 0;
        end else begin
            // Encode data
            encoded_bit1 = data_in ^ (shift_reg[1] & data_in) ^ (shift_reg[2] & data_in);
            encoded_bit2 = data_in ^ shift_reg[2];
        end
    end
    
    // Clock logic
    always @ (clock) begin
        shift_reg = (data_in << 2) | (shift_reg << 1);
    end
endmodule