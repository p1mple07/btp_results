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
	output reg [DATA_WIDTH+1:0] result2, 
	output reg done
);

localparam IDLE = 2'd0;
localparam COMPUTE = 2'd1;
localparam DONE = 2'd2;

reg [DATA_WIDTH-1:0] result1_reg;
reg [DATA_WIDTH+1:0] result2_reg;
reg [1:0] state_reg;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		state_reg <= IDLE;
		result1_reg <= 0;
		result2_reg <= 0;
	end else begin
		case (state_reg)
			IDLE: begin
				if (start) begin
					state_reg <= COMPUTE;
					result1_reg <= 0;
					result2_reg <= 0;
				end
			end
			
			COMPUTE: begin
				result1_reg <= w_in * x_in >> 1; // Prevent overflow due to multiplication when inputs have maximum or minimum values
				result2_reg <= b_in + (x_in >> 2); // Prevent overflow due to addition when inputs have maximum or minimum values
				state_reg <= DONE;
			end
			
			DONE: begin
				done <= 1; // Assert `done` signal for 1 clock cycle
				state_reg <= IDLE;
			end
		endcase
	end
end

assign result1 = result1_reg;
assign result2 = result2_reg;

endmodule