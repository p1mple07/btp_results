module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
    logic new_bit;

    // Primitive polynomial considered for 8-bit Linear Feedback Shift Register (LFSR) with Fibonacci configuration is x^8+x^6+x^5+x+1 
    // In Fibonacci configuration, the taps are at positions 7,6,5,1,0

    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
            lfsr_out <= lfsr_seed;
        else
            assign new_bit = lfsr_out[7] ^ lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1] ^ lfsr_out[0];
            lfsr_out = {new_bit, lfsr_out[7], lfsr_out[6], lfsr_out[5], lfsr_out[4], lfsr_out[3], lfsr_out[2], lfsr_out[1]};
        end
    end
endmodule