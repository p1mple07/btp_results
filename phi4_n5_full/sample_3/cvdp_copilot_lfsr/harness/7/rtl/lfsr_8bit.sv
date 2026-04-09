module lfsr_8bit(input clock, input reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
    // Fibonacci configuration LFSR based on primitive polynomial: x^8 + x^6 + x^5 + x + 1
    // Tap positions: lfsr_out[6], lfsr_out[5], lfsr_out[1], and lfsr_out[0]
    // On every positive clock edge (when reset is high), the feedback bit is computed and shifted into the MSB.
    always_ff @(posedge clock or negedge reset) begin
        if (!reset)
            lfsr_out <= lfsr_seed;  // Load seed when asynchronous reset is active (logic LOW)
        else begin
            // Compute feedback bit as XOR of tapped bits
            bit [0] feedback = lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1] ^ lfsr_out[0];
            // Shift right: new MSB is the feedback, and the rest shift right by one bit
            lfsr_out <= {feedback, lfsr_out[7:1]};
        end
    end
endmodule