module rc5_enc_16bit(
	input wire clock,
	input wire reset,
	input wire enc_start,
	input wire [15:0] p,
	output reg [15:0] c,
	output wire enc_done
);

	// Initialize S-box variables
 Reg [7:0] s0,s1,s2,s3;

	// Instantiate CA for S-box generation
 inst CA_2 (s0,s1,s2,s3);

	// Wire connections
	wire q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15;

	// Clock and reset control
	always wire {
		clk = ~reset ? ~clock;
		reset ? valid <= 0 : valid <= 1;
	}

	// Main processing
	always_ff @posedge clock begin
		if (reset || !enc_start) 
			// Initialize A and B with plaintext
			a <= p[7:0];
			b <= p[8:15];
			s0_val <= q0;
			s1_val <= q1;
		else 
			// Perform RC5 encryption
			a = (a + s0_val) % 256;
			b = (b + s1_val) % 256;
			
			// First round computation
			new_a = ( (a ^ b) << (b) ) % 256;
			new_a = (new_a + s2_val) % 256;
			
			new_b = ( (b ^ a) << (a) ) % 256;
			new_b = (new_b + s3_val) % 256;
			
			c = {new_a, new_b};
			enc_done <= 1;
	end
endmodule