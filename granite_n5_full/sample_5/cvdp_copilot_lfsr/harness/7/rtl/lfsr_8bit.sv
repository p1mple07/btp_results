module lfsr_8bit(input clock,reset,input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
	// Primitive polynomial considered for 8-bit LFSR with Fibonacci configuration is x<sup>8</sup>+x<sup>6</sup>+x<sup>5</sup>+x+1
	logic q1,q2,q3,q4,q5,q6,q7;
	
	// Internal XORing based on the primitive polynomial
	assign q1 = lfsr_out[7]^lfsr_out[1];
	assign q2 = lfsr_out[6]^lfsr_out[0];
	assign q3 = lfsr_out[5]^lfsr_out[0];
	assign q4 = lfsr_out[4]^lfsr_out[0];
	assign q5 = lfsr_out[3]^lfsr_out[0];
	assign q6 = lfsr_out[2]^lfsr_out[0];
	assign q7 = lfsr_out[1]^lfsr_out[0];
	
	always_ff @(posedge clock or negedge reset)
	begin
		if(!reset) begin // Reset condition
			lfsr_out <= lfsr_seed; // Load seed into LFSR output
		end else begin
			lfsr_out <= {q1, q2, q3, q4, q5, q6, q7, lfsr_out[0]}; // Shift register based on the primitive polynomial
		end
	end
endmodule