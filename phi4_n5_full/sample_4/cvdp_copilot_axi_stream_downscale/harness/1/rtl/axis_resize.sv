module axis_resize (
  input                                           clk,          // Global clock signal
  input                                           resetn,       // Synchronous active-LOW reset
  input                                           s_valid,      // Slave valid signal
  output  reg                                     s_ready,      // Slave ready signal
  input       [15:0]  s_data,                                   // 16-bit slave data
  output  reg                                     m_valid,      // Master valid signal
  input                                           m_ready,      // Master ready signal
  output  reg [7:0] m_data                                      // 8-bit master data
);

  // Internal register to latch the incoming 16-bit data
  reg [15:0] data_reg;
  
  // State register: 0 = IDLE, 1 = FIRST_BYTE, 2 = SECOND_BYTE
  reg [1:0] state;
  
  // Local parameters for state encoding
  localparam IDLE   = 2'd0,
             FIRST  = 2'd1,
             SECOND = 2'd2;
  
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // Synchronous reset: clear state, deassert outputs, and set data_reg to 0
      state      <= IDLE;
      s_ready    <= 1'b0;
      m_valid    <= 1'b0;
      m_data     <= 8'd0;
      data_reg   <= 16'd0;
    end else begin
      case (state)
        IDLE: begin
          // In IDLE state, we are ready to accept a new slave transaction.
          s_ready <= 1'b1;
          m_valid <= 1'b0;
          if (s_valid) begin
            // Latch the incoming 16-bit data and move to FIRST_BYTE state.
            data_reg <= s_data;
            state    <= FIRST;
          end
        end
        FIRST: begin
          // In FIRST_BYTE state, we output the high 8 bits.
          s_ready <= 1'b0;  // Busy; cannot accept new s_data
          m_valid <= 1'b1;
          m_data  <= data_reg[15:8];
          // Wait for master handshake.
          if (m_ready) begin
            state <= SECOND;
          end
        end
        SECOND: begin
          // In SECOND_BYTE state, we output the low 8 bits.
          s_ready <= 1'b0;
          m_valid <= 1'b1;
          m_data  <= data_reg[7:0];
          // Wait for master handshake.
          if (m_ready) begin
            state <= IDLE;  // Transaction complete; return to idle.
          end
        end
        default: state <= IDLE;
      endcase
    end
  end

endmodule