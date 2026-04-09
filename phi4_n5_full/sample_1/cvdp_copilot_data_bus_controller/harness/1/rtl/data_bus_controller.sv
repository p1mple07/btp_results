module data_bus_controller #(
  parameter AFINITY = 0
)(
  input         clk,
  input         rst_n,

  output        m0_read,
  input         m0_valid,
  input  [31:0] m0_data,

  output        m1_read,
  input         m1_valid,
  input  [31:0] m1_data,

  input         s_read,
  output        s_valid,
  output [31:0] s_data
);

  // State encoding: 0 = IDLE, 1 = FORWARD
  localparam IDLE     = 1'b0;
  localparam FORWARD  = 1'b1;

  // Internal registers
  reg         state;          // Current state of the controller
  reg [31:0]  pending_data;   // Holds the captured transaction data
  reg         s_read_reg;     // Registered version of s_read for sampling

  // Masters ready signals: when in IDLE state the controller is ready to accept a transaction.
  assign m0_read = (state == IDLE);
  assign m1_read = (state == IDLE);

  // Slave interface: when in FORWARD state and s_read is high, output the captured transaction.
  assign s_valid = (state == FORWARD) ? s_read : 1'b0;
  assign s_data  = (state == FORWARD) ? pending_data : 32'b0;

  // State machine to implement one-cycle latency and arbitration.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= IDLE;
      pending_data <= 32'b0;
      s_read_reg   <= 1'b0;
    end else begin
      // Register the slave ready signal from the previous cycle.
      s_read_reg <= s_read;

      case (state)
        IDLE: begin
          // When in IDLE, if the slave was ready in the previous cycle,
          // capture a transaction from the masters.
          if (s_read_reg) begin
            if (m0_valid && ~m1_valid) begin
              pending_data <= m0_data;
            end else if (~m0_valid && m1_valid) begin
              pending_data <= m1_data;
            end else if (m0_valid && m1_valid) begin
              // If both masters are valid simultaneously, use AFINITY to decide.
              if (AFINITY == 0)
                pending_data <= m0_data;
              else
                pending_data <= m1_data;
            end
            // Move to FORWARD state to output the captured transaction.
            state <= FORWARD;
          end
          // Else remain in IDLE.
        end

        FORWARD: begin
          // In FORWARD state, if the slave is ready, output the transaction and return to IDLE.
          if (s_read)
            state <= IDLE;
          // Otherwise, hold the transaction (waiting for the slave to accept it).
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule