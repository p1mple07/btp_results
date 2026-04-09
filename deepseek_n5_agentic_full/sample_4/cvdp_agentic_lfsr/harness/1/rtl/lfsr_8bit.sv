module lfsr_8bit (
    input wire clk,
    input wire rst,
    input wire [7:0] seed,
    output reg [7:0] lfsr_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr_out <= 8'b00000001;
        else begin
            // Calculate feedback bit using taps at positions 7, 5, 4, and 3
            wire feedback_bit = lfsr_out[7] ^ lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[3];
            // Shift left and insert feedback bit as the new LSB
            lfsr_out <= (lfsr_out << 1) | feedback_bit;
        end
    end
endmodule