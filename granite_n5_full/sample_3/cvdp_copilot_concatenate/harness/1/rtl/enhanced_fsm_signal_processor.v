module enhanced_fsm_signal_processor(
  input  logic             i_clk,
  input  logic             i_rst_n,
  input  logic             i_enable,
  input  logic             i_clear,
  input  logic             i_ack,
  input  logic             i_fault,
  input  logic [4:0]      i_vector_1,
  input  logic [4:0]      i_vector_2,
  input  logic [4:0]      i_vector_3,
  input  logic [4:0]      i_vector_4,
  input  logic [4:0]      i_vector_5,
  input  logic [4:0]      i_vector_6,
  output logic             o_ready,
  output logic             o_error,
  output logic [1:0]      o_fsm_status,
  output logic [7:0]      o_vector_1,
  output logic [7:0]      o_vector_2,
  output logic [7:0]      o_vector_3,
  output logic [7:0]      o_vector_4
);

  enum logic [1:0] {
    IDLE = 2'b00,
    PROCESS = 2'b01,
    READY = 2'b10,
    FAULT = 2'b11
  } fsm_state, next_state;
  
  assign o_fsm_status = fsm_state;
  
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      // Reset
      fsm_state <= IDLE;
      o_ready <= 1'b0;
      o_error <= 1'b0;
      // Concatenate vectors and split them
      o_vector_1 <= 8'b0;
      o_vector_2 <= 8'b0;
      o_vector_3 <= 8'b0;
      o_vector_4 <= 8'b0;
    end else begin
      // Update state based on inputs
      case (fsm_state)
        IDLE: begin
          if (i_enable) begin
            // Start processing
            fsm_state <= PROCESS;
          end else begin
            // Wait for enable signal
            fsm_state <= IDLE;
          end
        end
        PROCESS: begin
          // Concatenate vectors and split them
          o_vector_1 <= { i_vector_1[4:0], i_vector_2[4:0], i_vector_3[4:0], i_vector_4[4:0], i_vector_5[4:0], i_vector_6[4:0] };
          o_vector_2 <= { i_vector_1[4:0], i_vector_2[4:0], i_vector_3[4:0], i_vector_4[4:0], i_vector_5[4:0], i_vector_6[4:0] };
          o_vector_3 <= { i_vector_1[4:0], i_vector_2[4:0], i_vector_3[4:0], i_vector_4[4:0], i_vector_5[4:0], i_vector_6[4:0] };
          o_vector_4 <= { i_vector_1[4:0], i_vector_2[4:0], i_vector_3[4:0], i_vector_4[4:0], i_vector_5[4:0], i_vector_6[4:0] };
          // Check for fault
          if (i_fault) begin
            // Handle fault
            fsm_state <= FAULT;
          end else begin
            // Move to ready state
            fsm_state <= READY;
          end
        end
        READY: begin
          // Output signals
          o_ready <= 1'b1;
          // Check for fault
          if (i_fault) begin
            // Handle fault
            fsm_state <= FAULT;
          end else begin
            // Transition back to idle
            fsm_state <= IDLE;
          end
        end
        FAULT: begin
          // Set error flag
          o_error <= 1'b1;
          // Wait for clear signal
          if (i_clear &&!i_fault) begin
            // Clear fault and transition back to idle
            fsm_state <= IDLE;
          end
        end
        default: ;
      endcase
    end
  end
  
  always_comb begin
    next_state = IDLE;
    case (fsm_state)
      IDLE: begin
        if (i_enable) begin
          next_state = PROCESS;
        end
      end
      PROCESS: begin
        if (i_fault) begin
          next_state = FAULT;
        end else begin
          next_state = READY;
        end
      end
      READY: begin
        next_state = IDLE;
      end
      FAULT: begin
        next_state = IDLE;
      end
      default: ;
    endcase
  end
  
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      // Reset state
      fsm_state <= IDLE;
      o_ready <= 1'b0;
      o_error <= 1'b0;
    end else begin
      // Update state
      fsm_state <= next_state;
      o_ready <= 1'b0;
      o_error <= 1'b0;
    end
  end
endmodule