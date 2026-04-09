module fsm_linear_reg (
  input clk,
  input reset,
  input start,
  input [DATA_WIDTH-1:0] x_in,
  input [DATA_WIDTH-1:0] w_in,
  input [DATA_WIDTH-1:0] b_in,
  output reg [DATA_WIDTH-1:0] result1,
  output reg [DATA_WIDTH+1:0] result2,
  output reg done
);

  // Define state variables
  reg [1:0] state;
  reg [DATA_WIDTH-1:0] temp_result1;
  reg [DATA_WIDTH+1:0] temp_result2;

  // State transition logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      result1 <= 0;
      result2 <= 0;
      done <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (start == 1) begin
            state <= COMPUTE;
            temp_result1 <= 0;
            temp_result2 <= 0;
          end
        end
        COMPUTE: begin
          temp_result1 <= w_in * x_in;
          temp_result2 <= b_in + (x_in >> 2);
          state <= DONE;
        end
        DONE: begin
          done <= 1;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

  // Assign final results
  assign result1 = temp_result1;
  assign result2 = temp_result2;

endmodule