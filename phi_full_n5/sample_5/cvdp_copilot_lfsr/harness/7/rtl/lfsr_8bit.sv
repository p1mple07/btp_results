
module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	logic q0, q1, q2, q3, q4, q5, q6, q7;
	//Primitive polynomial considered for 8-bit Linear Feedback Shift Register (LFSR) with Fibonacci configuration is x^8+x^6+x^5+x+1 
	
	always_ff @(posedge clock or negedge reset)
	begin
		if (!reset)
			lfsr_out <= lfsr_seed;//If reset is at logic LOW, the initial seed will be loaded into LFSR's 8-bit output
		else
		begin
			q0 <= lfsr_out[7];
			q1 <= q0 ^ lfsr_out[6];
			q2 <= q1 ^ lfsr_out[5];
			q3 <= q2 ^ lfsr_out[1];
			q4 <= q3 ^ lfsr_out[0];
			q5 <= q4 ^ lfsr_out[7];
			q6 <= q5 ^ lfsr_out[6];
			q7 <= q6 ^ lfsr_out[5];
			lfsr_out <= {q7, q6, q5, q4, q3, q2, q1, q0};//Shift register based on the Fibonacci polynomial
		end
	end
endmodule
