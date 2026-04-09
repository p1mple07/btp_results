module enhanced_fsm_signal_processor (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire         i_enable,
    input  wire         i_clear,
    input  wire         i_ack,
    input  wire         i_fault,
    input  wire [4:0]   i_vector_1,
    input  wire [4:0]   i_vector_2,
    input  wire [4:0]   i_vector_3,
    input  wire [4:0]   i_vector_4,
    input  wire [4:0]   i_vector_5,
    input  wire [4:0]   i_vector_6,
    output reg          o_ready,
    output reg          o_error,
    output reg [1:0]    o_fsm_status,
    output reg [7:0]    o_vector_1,
    output reg [7:0]    o_vector_2,
    output reg [7:0]    o_vector_3,
    output reg [7:0]    o_vector_4
);

  // State encoding
  localparam IDLE   = 2'b00;
  localparam PROCESS = 2'b01;
  localparam READY   = 2'b10;
  localparam FAULT   = 2'b11;

  reg [1:0] state, next_state;

  // Concatenate six 5-bit vectors and append two 1's at the LSB to form a 32-bit bus.
  // The order is: MSB: i_vector_1, then i_vector_2, ..., then i_vector_6, and finally 2'b11.
  wire [31:0] bus32;
  assign bus32 = { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 };

  // Next state combinational logic.
  // Note: i_fault takes precedence over any other input.
  always @(*) begin
    if (i_fault)
      next_state = FAULT;
    else
      case (state)
        IDLE: begin
          if (i_enable)
            next_state = PROCESS;
          else
            next_state = IDLE;
        end
        PROCESS: begin
          next_state = READY;
        end
        READY: begin
          if (i_ack)
            next_state = IDLE;
          else
            next_state = READY;
        end
        FAULT: begin
          if (i_clear && !i_fault)
            next_state = IDLE;
          else
            next_state = FAULT;
        end
        default: next_state = IDLE;
      endcase
  end

  // Sequential always block: state register update and output assignments.
  // All outputs and state transitions are synchronous to i_clk.
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state          <= IDLE;
      o_ready        <= 1'b0;
      o_error        <= 1'b0;
      o_fsm_status   <= IDLE;
      o_vector_1     <= 8'b0;
      o_vector_2     <= 8'b0;
      o_vector_3     <= 8'b0;
      o_vector_4     <= 8'b0;
    end
    else begin
      // If i_clear is asserted, clear outputs.
      if (i_clear) begin
        o_ready        <= 1'b0;
        o_error        <= 1'b0;
        o_vector_1     <= 8'b0;
        o_vector_2     <= 8'b0;
        o_vector_3     <= 8'b0;
        o_vector_4     <= 8'b0;
      end
      else begin
        case (state)
          IDLE: begin
            o_ready        <= 1'b0;
            o_error        <= 1'b0;
            o_fsm_status   <= IDLE;
            o_vector_1     <= 8'b0;
            o_vector_2     <= 8'b0;
            o_vector_3     <= 8'b0;
            o_vector_4     <= 8'b0;
          end
          PROCESS: begin
            // In PROCESS state, form the 32-bit bus and split it into four 8-bit outputs.
            o_vector_1     <= bus32[31:24];
            o_vector_2     <= bus32[23:16];
            o_vector_3     <= bus32[15:8];
            o_vector_4     <= bus32[7:0];
            o_ready        <= 1'b0;
            o_error        <= 1'b0;
            o_fsm_status   <= PROCESS;
          end
          READY: begin
            // In READY state, indicate that processing is complete.
            o_ready        <= 1'b1;
            o_error        <= 1'b0;
            o_fsm_status   <= READY;
            // Outputs remain valid as produced in PROCESS.
          end
          FAULT: begin
            // In FAULT state, assert error and clear outputs.
            o_ready        <= 1'b0;
            o_error        <= 1'b1;
            o_fsm_status   <= FAULT;
            o_vector_1     <= 8'b0;
            o_vector_2     <= 8'b0;
            o_vector_3     <= 8'b0;
            o_vector_4     <= 8'b0;
          end
          default: begin
            o_ready        <= 1'b0;
            o_error        <= 1'b0;
            o_fsm_status   <= IDLE;
            o_vector_1     <= 8'b0;
            o_vector_2     <= 8'b0;
            o_vector_3     <= 8'b0;
            o_vector_4     <= 8'b0;
          end
        endcase
      end
      state <= next_state;
    end
  end

endmodule