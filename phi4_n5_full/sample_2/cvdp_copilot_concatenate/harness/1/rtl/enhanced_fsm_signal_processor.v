module enhanced_fsm_signal_processor(
    input         i_clk,
    input         i_rst_n,
    input         i_enable,
    input         i_clear,
    input         i_ack,
    input         i_fault,
    input  [4:0]  i_vector_1,
    input  [4:0]  i_vector_2,
    input  [4:0]  i_vector_3,
    input  [4:0]  i_vector_4,
    input  [4:0]  i_vector_5,
    input  [4:0]  i_vector_6,
    output reg    o_ready,
    output reg    o_error,
    output reg [1:0] o_fsm_status,
    output reg [7:0] o_vector_1,
    output reg [7:0] o_vector_2,
    output reg [7:0] o_vector_3,
    output reg [7:0] o_vector_4
);

  // State encoding: IDLE = 00, PROCESS = 01, READY = 10, FAULT = 11
  localparam IDLE   = 2'b00;
  localparam PROCESS= 2'b01;
  localparam READY  = 2'b10;
  localparam FAULT  = 2'b11;

  // Combinational bus: Concatenate six 5-bit vectors into a 30-bit bus,
  // then append two '1' bits at the LSB to form a 32-bit bus.
  // Mapping: o_vector_1 = bus[31:24], o_vector_2 = bus[23:16],
  //          o_vector_3 = bus[15:8],  o_vector_4 = bus[7:0]
  wire [31:0] bus;
  assign bus = { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 };

  reg [1:0] state;

  // Synchronous state and output update
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state             <= IDLE;
      o_ready           <= 1'b0;
      o_error           <= 1'b0;
      o_vector_1        <= 8'b0;
      o_vector_2        <= 8'b0;
      o_vector_3        <= 8'b0;
      o_vector_4        <= 8'b0;
    end
    else begin
      // Fault precedence: if i_fault is asserted, force state to FAULT
      if (i_fault) begin
        state <= FAULT;
      end
      else begin
        case (state)
          IDLE: begin
            if (i_enable)
              state <= PROCESS;
            else
              state <= IDLE;
          end
          PROCESS: begin
            state <= READY;
          end
          READY: begin
            if (i_ack)
              state <= IDLE;
            else
              state <= READY;
          end
          FAULT: begin
            // In FAULT, transition to IDLE only when i_clear is asserted
            if (i_clear)
              state <= IDLE;
            else
              state <= FAULT;
          end
          default: state <= IDLE;
        endcase
      end

      // Update outputs based on current state
      case (state)
        IDLE: begin
          o_ready           <= 1'b0;
          o_error           <= 1'b0;
          o_vector_1        <= 8'b0;
          o_vector_2        <= 8'b0;
          o_vector_3        <= 8'b0;
          o_vector_4        <= 8'b0;
        end
        PROCESS: begin
          o_ready           <= 1'b0;
          o_error           <= 1'b0;
          o_vector_1        <= bus[31:24];
          o_vector_2        <= bus[23:16];
          o_vector_3        <= bus[15:8];
          o_vector_4        <= bus[7:0];
        end
        READY: begin
          o_ready           <= 1'b1;
          o_error           <= 1'b0;
          o_vector_1        <= 8'b0;
          o_vector_2        <= 8'b0;
          o_vector_3        <= 8'b0;
          o_vector_4        <= 8'b0;
        end
        FAULT: begin
          o_ready           <= 1'b0;
          o_error           <= 1'b1;
          o_vector_1        <= 8'b0;
          o_vector_2        <= 8'b0;
          o_vector_3        <= 8'b0;
          o_vector_4        <= 8'b0;
        end
        default: begin
          o_ready           <= 1'b0;
          o_error           <= 1'b0;
          o_vector_1        <= 8'b0;
          o_vector_2        <= 8'b0;
          o_vector_3        <= 8'b0;
          o_vector_4        <= 8'b0;
        end
      endcase
    end
  end

  // Update FSM status output (synchronous to clock)
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
      o_fsm_status <= IDLE;
    else
      o_fsm_status <= state;
  end

endmodule