
module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	logic q1,q2,q3,q4,q5,q6,q7;
	
	always_ff @(posedge clock or negedge reset)
	begin
		if (!reset)
			lfsr_out <= lfsr_seed;//If reset is at logic LOW, the initial seed will be loaded into LFSR's 8-bit output
		else
			lfsr_out <= {lfsr_out[7],q1,q2,q3,q4,q5,q6,q7};//Shift register based on the Fibonacci polynomial
		q1 <= lfsr_out[7] ^ lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1] ^ lfsr_out[0];
		q2 <= lfsr_out[6];
		q3 <= lfsr_out[5];
		q4 <= lfsr_out[4];
		q5 <= lfsr_out[3];
		q6 <= lfsr_out[2];
		q7 <= lfsr_out[1];
	end
endmodule
