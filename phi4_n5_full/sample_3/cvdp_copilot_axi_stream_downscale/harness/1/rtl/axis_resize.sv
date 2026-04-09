module axis_resize (
  input  wire           clk,
  input  wire           resetn,
  input  wire           s_valid,
  output reg            s_ready,
  input  wire [15:0]    s_data,
  output reg            m_valid,
  input  wire           m_ready,
  output reg [7:0]      m_data
);

  // Define a two-bit state type
  typedef enum logic [1:0] {
    IDLE      = 2'b00,
    SEND_UPPER = 2'b01,
    SEND_LOWER = 2'b10
  } state_t;

  state_t state, next_state;
  reg [15:0] data_reg;

  // Next state combinational logic
  always_comb begin
    case (state)
      IDLE: begin
        if (s_valid)
          next_state = SEND_UPPER;
        else
          next_state = IDLE;
      end
      SEND_UPPER: begin
        if (m_ready)
          next_state = SEND_LOWER;
        else
          next_state = SEND_UPPER;
      end
      SEND_LOWER: begin
        if (m_ready)
          next_state = IDLE;
        else
          next_state = SEND_LOWER;
      end
      default: next_state = IDLE;
    endcase
  end

  // Sequential logic: state register and output updates
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      state      <= IDLE;
      s_ready    <= 1'b0;
      m_valid    <= 1'b0;
      m_data     <= 8'd0;
      data_reg   <= 16'd0;
    end else begin
      state <= next_state;
      case (state)
        IDLE: begin
          if (s_valid) begin
            // Capture the 16-bit data and output the upper 8 bits
            data_reg  <= s_data;
            s_ready   <= 1'b0;  // Not ready for a new slave transaction
            m_valid   <= 1'b1;
            m_data    <= data_reg[15:8];
          end else begin
            s_ready   <= 1'b1;  // Ready to accept a new transaction
            m_valid   <= 1'b0;
          end
        end
        SEND_UPPER: begin
          // Hold m_valid high until the master accepts the high-part transaction
          m_valid   <= 1'b1;
          // m_data remains the high 8 bits (data_reg[15:8]) from the previous cycle
        end
        SEND_LOWER: begin
          // Drive the lower 8 bits and wait for m_ready to accept the transaction
          m_valid   <= 1'b1;
          if (m_ready) begin
            s_ready  <= 1'b1;  // Transaction complete; ready for a new slave transfer
            m_valid  <= 1'b0;
          end
          m_data    <= data_reg[7:0];
        end
      endcase
    end
  end

endmodule