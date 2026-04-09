module control_fsm (
    input clk,
    input rst_async_n,
    input i_enable,
    input i_subsampling,
    input i_valid,
    input o_valid,
    input i_calc_valid,
    input i_calc_fail,
    input i_wait,
    output reg o_start_calc,
    output reg o_calc_fail,
    output reg o_valid,
    output reg o_start_calc,
    output reg o_wait,
    output reg o_done
);

  localparam PROC_CONTROL_CAPTURE_ST = 4'b0000;
  localparam PROC_DATA_CAPTURE_ST = 4'b0001;
  localparam PROC_CALC_START_ST = 4'b0010;
  localparam PROC_CALC_ST = 4'b0011;
  localparam PROC_WAIT_ST = 4'b1000;

  reg [3:0] state;
  reg [31:0] timeout_counter;
  reg [31:0] wait_threshold;
  reg i_valid_in;
  reg i_calc_valid_out;
  reg o_start_calc_out;
  reg o_calc_fail_out;
  reg o_valid_out;
  reg o_start_calc_out;

  initial begin
    state = PROC_CONTROL_CAPTURE_ST;
  end

  always @(posedge clk or posedge rst_async_n) begin
    if (!rst_async_n) begin
      state <= PROC_CONTROL_CAPTURE_ST;
      timeout_counter <= 32'd0;
      wait_threshold <= 32'd0;
      o_start_calc_out <= 1'b0;
      o_calc_fail_out <= 1'b0;
      o_valid_out <= 1'b0;
      o_start_calc_out <= 1'b0;
      o_done <= 1'b0;
    end else begin
      case(state)
        PROC_CONTROL_CAPTURE_ST: begin
          // Capture control signals
          if (i_enable) begin
            state <= PROC_DATA_CAPTURE_ST;
          end
        end
        PROC_DATA_CAPTURE_ST: begin
          // Count down with i_enable
          if (i_enable) begin
            timeout_counter <= timeout_counter - 1;
          end
          if (timeout_counter == 0) begin
            state <= PROC_CALC_START_ST;
          end
        end
        PROC_CALC_START_ST: begin
          // Wait for o_valid or timeout
          if (i_valid_in && !i_calc_fail_out) begin
            state <= PROC_CALC_ST;
          end else if (o_valid_out) begin
            state <= PROC_WAIT_ST;
          end
        end
        PROC_CALC_ST: begin
          // Wait for i_calc_valid or fail
          if (i_calc_valid_out) begin
            state <= PROC_WAIT_ST;
          end else if (i_calc_fail_out) begin
            state <= PROC_CONTROL_CAPTURE_ST;
          end
        end
        PROC_WAIT_ST: begin
          // Preload wait threshold
          if (i_wait) begin
            wait_threshold <= i_wait;
          end
          // Transition on timeout
          if (timeout_counter == 0) begin
            state <= PROC_CONTROL_CAPTURE_ST;
          end
        end
      endcase
    end
  end

endmodule
