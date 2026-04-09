
module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	logic q0,q1,q2,q3,q4,q5,q6,q7;
	
	//Feedback taps for Fibonacci configuration are at positions 7, 6, 1, 0
	assign q0 = lfsr_out[7] ^ lfsr_out[6] ^ lfsr_out[1] ^ lfsr_out[0];
	assign q1 = lfsr_out[6];
	assign q2 = lfsr_out[5];
	assign q3 = lfsr_out[4];
	assign q4 = lfsr_out[3];
	assign q5 = lfsr_out[2];
	assign q6 = lfsr_out[1];
	assign q7 = lfsr_out[0];

	always_ff @(posedge clock or negedge reset)
	begin
		if (!reset)
			lfsr_out <= lfsr_seed;//If reset is at logic LOW, the initial seed will be loaded into LFSR's 8-bit output
		else
			lfsr_out <= {lfsr_out[7],q0,q1,q2,q3,q4,q5,q6,q7};//Shift register based on the Fibonacci configuration
	end
endmodule
