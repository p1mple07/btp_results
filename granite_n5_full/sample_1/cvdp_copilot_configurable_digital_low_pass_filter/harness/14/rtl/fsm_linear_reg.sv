module fsm_linear_reg #(
	parameter DATA_WIDTH = 16
)(
	input wire clk, 
	input wire reset, 
	input wire start, 
	input wire [DATA_WIDTH-1:0] x_in, 
	input wire [DATA_WIDTH-1:0] w_in, 
	input wire [DATA_WIDTH-1:0] b_in, 
	output reg [DATA_WIDTH-1:0] result1, 
	output reg [DATA_WIDTH-1:0] result2, 
	output reg done
);

enum reg [1:0] {IDLE, COMPUTE, DONE} state, next_state;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		state <= IDLE;
		result1 <= 0;
		result2 <= 0;
		done <= 0;
	end else begin
		case(state)
			IDLE: begin
				if(start) begin
					next_state <= COMPUTE;
				end else begin
					next_state <= IDLE;
				end
			end
			COMPUTE: begin
				next_state <= DONE;
				result1 <= w_in * x_in >> 1;
				result2 <= b_in + (x_in >> 2);
			end
			DONE: begin
				next_state <= IDLE;
				done <= 1;
			end
			default: begin
				next_state <= IDLE;
			end
		endcase
	end
end

always @(posedge clk) begin
	state <= next_state;
end

endmodule