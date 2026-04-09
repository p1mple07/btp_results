module convolutional_encoder(
    input clock,
    input rst,
    input data_in,
    output encoded_bit1,
    output encoded_bit2
);
    reg q0, q1; // Shift register stages
    reg encoded_bit1, encoded_bit2;

    // Initialize outputs to 0
    always @* begin
        encoded_bit1 = 0;
        encoded_bit2 = 0;
    end

    // Shift register initialization
    initial begin
        q0 = 0;
        q1 = 0;
    end

    // Process each clock cycle
    clocked begin
        if (rst) begin
            encoded_bit1 = 0;
            encoded_bit2 = 0;
            q0 = 0;
            q1 = 0;
            $finish;
        end else begin
            // Compute encoded bits using generator polynomials
            encoded_bit1 = data_in ^ q0 ^ q1;
            encoded_bit2 = data_in ^ q1;
            
            // Shift register
            q0 = data_in;
            q1 = q0;
        end
    end
endmodule