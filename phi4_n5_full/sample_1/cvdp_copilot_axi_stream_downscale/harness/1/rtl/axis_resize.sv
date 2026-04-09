module axis_resize (
  input  clk,          // Global clock signal: Signals are sampled on the rising edge of clk
  input  resetn,       // The global reset signal: resetn is synchronous active-LOW reset.
  input  s_valid,      // Indicates that the slave is driving a valid transfer.
  output reg s_ready,  // Indicates that the slave can accept a transfer in the current cycle.
  input  [15:0] s_data,  // Primary payload data from slave.
  output reg m_valid,   // Indicates that the master is driving a valid transfer.
  input  m_ready,      // Indicates that the master can accept a transfer in the current cycle.
  output reg [7:0] m_data  // Primary payload data to master.
);

  // State encoding:
  // 0 = IDLE: ready to accept new input.
  // 1 = OUTPUT_SECOND: currently outputting the second (lower) 8 bits.
  reg state;

  // Register to hold the 16-bit input data for splitting.
  reg [15:0] data_reg;

  always @(posedge clk) begin
    if (!resetn) begin
      // Asynchronous reset: clear all registers.
      state     <= 1'b0;
      data_reg  <= 16'd0;
      m_valid   <= 1'b0;
      m_data    <= 8'd0;
      s_ready   <= 1'b0;
    end else begin
      // s_ready is high only in the IDLE state.
      s_ready <= (state == 1'b0) ? 1'b1 : 1'b0;

      case (state)
        1'b0: begin
          // IDLE state: ready to accept new data.
          if (s_valid) begin
            // Capture the 16-bit input data.
            data_reg <= s_data;
            // Output the upper 8 bits.
            m_valid  <= 1'b1;
            m_data   <= data_reg[15:8];
            // Move to the state to output the lower 8 bits.
            state    <= 1'b1;
          end else begin
            m_valid <= 1'b0;
          end
        end

        1'b1: begin
          // Currently outputting the lower 8 bits.
          if (m_ready) begin
            // When the master is ready, send the lower 8 bits.
            m_data  <= data_reg[7:0];
            // Transaction complete; return to IDLE.
            state   <= 1'b0;
            m_valid <= 1'b0;
          end
          // If m_ready is not asserted, hold the current state and keep m_valid asserted.
        end

        default: begin
          // Should never reach here.
          state   <= 1'b0;
          m_valid <= 1'b0;
        end
      endcase
    end
  end

endmodule