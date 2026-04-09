module lfsr_8bit(input clock, input reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	// Fibonacci configuration for 8-bit LFSR using primitive polynomial: x^8 + x^6 + x^5 + x + 1
	// Tap positions (excluding the new MSB): 7, 6, 5, 1, and 0.
	// Feedback is computed as: new MSB = old[6] XOR old[5] XOR old[1] XOR old[0]
	// The remaining bits are shifted right by one position.
	always_ff @(posedge clock or negedge reset) begin
		if (!reset)
			lfsr_out <= lfsr_seed; // Load seed when asynchronous reset is active (LOW)
		else begin
			// Use a temporary variable to capture the current state
			logic [7:0] temp;
			temp = lfsr_out;
			
			// Compute new MSB using tapped bits from the previous state
			lfsr_out[7] <= temp[6] ^ temp[5] ^ temp[1] ^ temp[0];
			
			// Shift the register: each bit takes the value of its immediate right neighbor
			lfsr_out[6] <= temp[7];
			lfsr_out[5] <= temp[6];
			lfsr_out[4] <= temp[5];
			lfsr_out[3] <= temp[4];
			lfsr_out[2] <= temp[3];
			lfsr_out[1] <= temp[2];
			lfsr_out[0] <= temp[1];
		end
	end
endmodule