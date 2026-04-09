module convolutional_encoder (
    input clk,
    input rst,
    input data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    // Shift register to hold previous 2 bits
    reg [1:0] shift_reg [0:2];

    // Generator polynomials
    localparam g1_poly = 3'b111; // Corresponds to x^2 + x + 1
    localparam g2_poly = 3'b101; // Corresponds to x^2 + 1

    // Encode logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= {1'b0, 1'b0}; // Reset shift register
            encoded_bit1 <= 1'b0;
            encoded_bit2 <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[1], shift_reg[0], data_in}; // Shift register

            // Generate encoded_bit1 using g1_poly
            if (shift_reg[2]) begin
                encoded_bit1 <= g1_poly;
            end else begin
                encoded_bit1 <= 1'b0;
            end

            // Generate encoded_bit2 using g2_poly
            if (shift_reg[1]) begin
                encoded_bit2 <= g2_poly;
            end else begin
                encoded_bit2 <= 1'b0;
            end
        end
    end

endmodule
