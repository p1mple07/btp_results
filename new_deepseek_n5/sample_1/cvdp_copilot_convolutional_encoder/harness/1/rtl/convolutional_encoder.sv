module convolutional_encoder(
    input clock,
    input rst,
    input data_in,
    output encoded_bit1,
    output encoded_bit2
);
    // Shift register for constraint length K=3
    reg shift_reg[2];
    // State to track if reset has been applied
    reg state = 0;
    
    // Process block to compute encoded bits
    process(clk) begin
        if (rst) begin
            // Initialize shift register and outputs on reset
            state = 0;
            shift_reg[0] = 0;
            shift_reg[1] = 0;
            encoded_bit1 = 0;
            encoded_bit2 = 0;
        elsif state == 0 begin
            // On first data bit after reset, initialize shift register
            shift_reg[0] = data_in;
            state = 1;
        elsif state == 1 begin
            // Shift in new data and shift out oldest bit
            shift_reg[1] = shift_reg[0];
            shift_reg[0] = data_in;
            state = 2;
        end
        else begin
            // Compute encoded bits using generator polynomials
            encoded_bit1 = data_in ^ shift_reg[0] ^ shift_reg[1];
            encoded_bit2 = data_in ^ shift_reg[1];
        end
    end
endmodule