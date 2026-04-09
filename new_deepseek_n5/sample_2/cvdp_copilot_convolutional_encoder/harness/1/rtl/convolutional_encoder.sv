module convolutional_encoder(
    input clock,
    input rst,
    input data_in,
    output encoded_bit1,
    output encoded_bit2
);

    // Shift register to store previous 2 bits
    reg [1:0] shift_reg;

    // Process to compute encoded bits
    process (clock, rst)
    begin
        // Reset outputs and shift register on reset
        if (rst == 1)
        begin
            encoded_bit1 = 0;
            encoded_bit2 = 0;
            shift_reg = 0;
            continue;
        end

        // Compute encoded bits using generator polynomials
        encoded_bit1 = data_in ^ (shift_reg[0] ^ shift_reg[1]);
        encoded_bit2 = data_in ^ shift_reg[1];
    end

    // Wire the shift register outputs to encoded bits
    encoded_bit1 <= shift_reg[0];
    encoded_bit2 <= shift_reg[1];
endmodule