module ping_pong_fifo_2_axi_stream #(
  parameter logic                              DATA_WIDTH          = 24,
  parameter logic                              STROBE_WIDTH        = DATA_WIDTH / 8,
  parameter logic                              USE_KEEP            = 0,
  parameter logic                              USER_IN_DATA        = 1
)(
  input  logic                                 rst,

  // Ping Pong FIFO Read Interface
  input  logic                                 i_block_fifo_rdy,
  output logic                                 o_block_fifo_act,
  input  logic [23:0]                          i_block_fifo_size,
  // Note: Although the port is declared as [(DATA_WIDTH+1)-1:0] (i.e. DATA_WIDTH bits),
  // the design specification indicates that i_block_fifo_data includes a “last” flag.
  // For this implementation we assume that the most-significant bit (MSB) of i_block_fifo_data
  // represents the “last” flag and the remaining DATA_WIDTH-1 bits are the actual data.
  input  logic [(DATA_WIDTH + 1) - 1:0]        i_block_fifo_data,
  output logic                                 o_block_fifo_stb,
  input  logic [3:0]                           i_axi_user,

  // AXI Stream Output
  input  logic                                 i_axi_clk,
  output logic [3:0]                           o_axi_user,
  input  logic                                 i_axi_ready,
  output logic [DATA_WIDTH - 1:0]              o_axi_data,
  output logic                                 o_axi_last,
  output logic                                 o_axi_valid
);

  // Internal signals
  // fifo_data_buffer holds the actual data from FIFO (excluding the MSB “last” flag)
  logic [DATA_WIDTH - 1:0] fifo_data_buffer;
  logic fifo_valid_buffer;
  logic fifo_last_buffer;

  // State machine states: IDLE and WAIT_AXI
  typedef enum logic {IDLE, WAIT_AXI} state_t;
  state_t state;

  // Reset and state machine
  always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
      state                   <= IDLE;
      fifo_valid_buffer       <= 1'b0;
      fifo_data_buffer        <= {DATA_WIDTH{1'b0}};
      fifo_last_buffer        <= 1'b0;
      o_block_fifo_act        <= 1'b0;
      o_block_fifo_stb        <= 1'b0;
      o_axi_valid             <= 1'b0;
      o_axi_data              <= {DATA_WIDTH{1'b0}};
      o_axi_last              <= 1'b0;
      o_axi_user              <= 4'd0;
    end
    else begin
      // Pass through user signal
      o_axi_user              <= i_axi_user;

      // Default assignments for FIFO control signals
      o_block_fifo_act        <= 1'b0;
      // We will drive o_block_fifo_stb only when a FIFO read is initiated.
      // It remains asserted until the AXI handshake completes.
      // (If AXI is not ready the strobe remains high.)

      case (state)
        IDLE: begin
          // Only initiate a FIFO read if FIFO is ready
          if (i_block_fifo_rdy) begin
            // Capture FIFO data:
            // Assume that i_block_fifo_data is organized as:
            // [DATA_WIDTH-1:1] = actual data, and bit [DATA_WIDTH] = last flag.
            fifo_data_buffer <= i_block_fifo_data[DATA_WIDTH - 1:1];
            fifo_last_buffer <= i_block_fifo_data[DATA_WIDTH];
            fifo_valid_buffer<= 1'b1;
            // Assert FIFO activate and strobe to indicate a read operation
            o_block_fifo_act  <= 1'b1;
            o_block_fifo_stb  <= 1'b1;
            // Move to WAIT_AXI state to transfer data to AXI
            state             <= WAIT_AXI;
          end
          else begin
            // FIFO not ready: remain idle.
            state             <= IDLE;
          end
        end

        WAIT_AXI: begin
          if (i_axi_ready) begin
            // AXI is ready to accept data: drive AXI outputs
            o_axi_data       <= fifo_data_buffer;
            o_axi_last       <= fifo_last_buffer;
            o_axi_valid      <= 1'b1;
            // Clear the FIFO valid buffer and deassert FIFO strobe after transfer
            fifo_valid_buffer<= 1'b0;
            o_block_fifo_stb <= 1'b0;
            // Return to IDLE to capture the next FIFO word
            state            <= IDLE;
          end
          else begin
            // AXI not ready: hold the valid signal and data until ready
            o_axi_data       <= fifo_data_buffer;
            o_axi_last       <= fifo_last_buffer;
            o_axi_valid      <= 1'b1;
            // Keep FIFO strobe asserted (indicating that a read has occurred)
            state            <= WAIT_AXI;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule