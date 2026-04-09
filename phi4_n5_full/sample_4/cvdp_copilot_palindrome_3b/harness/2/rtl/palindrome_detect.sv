module palindrome_detect #(parameter N = 3)(
    input  clk,
    input  reset,
    input  bit_stream,
    output reg palindrome_detected
);

    // Shift register to hold the previous two bits from the stream.
    reg [1:0] shift_reg;

    always @(posedge clk) begin
        if (reset) begin
            shift_reg      <= 2'b0;
            palindrome_detected <= 1'b0;
        end else begin
            // Shift in the new bit.
            shift_reg <= { shift_reg[0], bit_stream };

            // For a 3-bit window, a palindrome is detected if the first and third bits are equal.
            // Here, shift_reg[1] is the first bit and bit_stream is the third.
            if (shift_reg[1] == bit_stream)
                palindrome_detected <= 1'b1;
            else
                palindrome_detected <= 1'b0;
        end
    end

endmodule