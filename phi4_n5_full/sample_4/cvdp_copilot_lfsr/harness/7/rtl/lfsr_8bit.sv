module lfsr_8bit(input clock, input reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	// In the Fibonacci configuration, the new MSB is computed as the XOR of lfsr_out[6], lfsr_out[5], lfsr_out[1], and lfsr_out[0].
	// Then, the register shifts left, inserting the computed feedback at the MSB.
	always_ff @(posedge clock or negedge reset)
	begin
		if (!reset)
			lfsr_out <= lfsr_seed;  // Load the initial seed when reset is LOW.
		else
			lfsr_out <= { lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1] ^ lfsr_out[0], lfsr_out[7:1] };
		// The new MSB is the XOR of the tap bits, and the rest shift left.
	end
endmodule