module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	// Fibonacci configuration LFSR with primitive polynomial: x^8 + x^6 + x^5 + x + 1.
	// Tap positions (excluding the MSB and LSB): bit6, bit5, bit1, and bit0.
	// On each positive clock edge (when reset is HIGH), compute the feedback as:
	//   feedback = lfsr_out[6] XOR lfsr_out[5] XOR lfsr_out[1] XOR lfsr_out[0]
	// Then shift the register right by one bit and insert the feedback at the MSB.
	// When asynchronous reset is LOW, the seed is loaded into lfsr_out.
	always_ff @(posedge clock or negedge reset)
	begin
		if (!reset)
			lfsr_out <= lfsr_seed; // Load seed when reset is LOW
		else
			lfsr_out <= { lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1] ^ lfsr_out[0], lfsr_out[7:1] }; // Fibonacci shift
	end
endmodule