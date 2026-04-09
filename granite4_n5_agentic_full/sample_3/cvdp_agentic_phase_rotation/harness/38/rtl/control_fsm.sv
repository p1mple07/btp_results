module control_fsm #(
  parameter NBW_WAIT = 32
)(
  // Clocking
  input wire clk,
  input wire rst_async_n,
  
  // Inputs
  input wire i_enable,
  input wire i_subsampling,
  input wire i_valid,
  input wire i_calc_valid,
  input wire i_calc_fail,
  input wire [NBW_WAIT-1:0] i_wait,
  
  // Outputs
  output logic o_start_calc,
  output logic o_valid,
  output logic o_subsampling
);

  // Define the FSM state enum
  typedef enum logic[1:0] {
    PROC_CONTROL_CAPTURE_ST,
    PROC_DATA_CAPTURE_ST,
    PROC_CALC_START_ST,
    PROC_CALC_ST,
    PROC_WAIT_ST
  } proc_fsm_state_e;

  // Define the FSM state variables
  logic start_calc;
  proc_fsm_state_e fsm_state;
  logic [NBW_WAIT-1:0] wait_counter;

  // Implement the FSM logic
  always_ff @(posedge clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
      fsm_state <= PROC_CONTROL_CAPTURE_ST;
      wait_counter <= 0;
      o_start_calc <= 1'b0;
      o_valid <= 1'b0;
      o_subsampling <= 1'b0;
    end else begin
      case(fsm_state)
        PROC_CONTROL_CAPTURE_ST: begin
          if (i_enable && i_valid) begin
            fsm_state <= PROC_DATA_CAPTURE_ST;
            wait_counter <= $urandom_range(16, 8);
          end
        end
        PROC_DATA_CAPTURE_ST: begin
          if (wait_counter > 0) begin
            wait_counter <= wait_counter - 1;
          end else begin
            fsm_state <= PROC_CALC_START_ST;
          end
        end
        PROC_CALC_START_ST: begin
          if (i_calc_valid) begin
            fsm_state <= PROC_CALC_ST;
          end
        end
        PROC_CALC_ST: begin
          if (i_calc_valid) begin
            fsm_state <= PROC_WAIT_ST;
          end else if (i_calc_fail) begin
            fsm_state <= PROC_CONTROL_CAPTURE_ST;
          end
        end
        PROC_WAIT_ST: begin
          if (wait_counter > 0) begin
            wait_counter <= wait_counter - 1;
          end else if (i_valid) begin
            fsm_state <= PROC_CALC_START_ST;
          end
        end
      endcase
    end
  end

  // Exported signals
  assign start_calc = (fsm_state == PROC_CALC_START_ST);
  assign o_valid = (fsm_state == PROC_CONTROL_CAPTURE_ST || fsm_state == PROC_DATA_CAPTURE_ST || fsm_state == PROC_CALC_START_ST);
  assign o_subsampling = i_subsampling;

endmodule