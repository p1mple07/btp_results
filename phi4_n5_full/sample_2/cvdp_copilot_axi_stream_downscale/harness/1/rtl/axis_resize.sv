module axis_resize (
  input                                           clk,          // Global clock signal
  input                                           resetn,       // Synchronous active-LOW reset
  input                                           s_valid,      // Indicates slave is driving a valid transfer
  output  reg                                     s_ready,      // Indicates that the slave can accept a transfer
  input       [15:0]  s_data,                      // 16-bit payload data from slave
  output  reg                                     m_valid,      // Indicates that the master is driving a valid transfer
  input                                           m_ready,      // Indicates that the master is ready to accept a transfer
  output  reg [7:0] m_data                       // 8-bit payload data to master
);

  // Internal register to hold the incoming 16-bit data
  reg [15:0] data_reg;
  // State machine: 0 = idle (waiting for input), 1 = sending high byte, 2 = sending low byte
  reg [1:0] state;

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      state      <= 2'd0;
      s_ready    <= 1'b0;
      m_valid    <= 1'b0;
      m_data     <= 8'b0;
      data_reg   <= 16'b0;
    end else begin
      case (state)
        2'd0: begin
          // Idle state: ready to accept a new transaction
          s_ready <= 1'b1;
          m_valid <= 1'b0;
          if (s_valid) begin
            // Capture the 16-bit data and move to sending high byte
            data_reg <= s_data;
            state    <= 2'd1;
          end
        end
        2'd1: begin
          // Sending high byte (upper 8 bits)
          m_valid <= 1'b1;
          m_data  <= data_reg[15:8];
          s_ready <= 1'b0;  // Not ready for new input until current transaction is complete
          if (m_ready) begin
            state <= 2'd2;
          end
        end
        2'd2: begin
          // Sending low byte (lower 8 bits)
          m_valid <= 1'b1;
          m_data  <= data_reg[7:0];
          s_ready <= 1'b0;
          if (m_ready) begin
            // Transaction complete, return to idle state
            state <= 2'd0;
          end
        end
        default: state <= 2'd0;
      endcase
    end
  end

endmodule