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

  // Internal buffers to hold data from FIFO
  logic [DATA_WIDTH - 1:0] fifo_data_buffer;
  logic                  fifo_valid_buffer;
  logic                  fifo_last_buffer;

  // State declaration for simple FSM control
  typedef enum logic {IDLE = 1'b0, DATA_LOADED = 1'b1} state_t;
  state_t state;

  // Pass through the AXI user signal
  assign o_axi_user = i_axi_user;

  // Synchronous state machine and data transfer logic
  always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
      state            <= IDLE;
      o_block_fifo_act <= 1'b0;
      o_axi_valid      <= 1'b0;
      fifo_data_buffer <= {DATA_WIDTH{1'b0}};
      fifo_valid_buffer<= 1'b0;
      fifo_last_buffer <= 1'b0;
    end else begin
      // Default assignments for outputs
      o_block_fifo_act <= 1'b0;
      o_axi_valid      <= 1'b0;
      o_block_fifo_stb <= 1'b0;
      o_axi_data       <= fifo_data_buffer;
      o_axi_last       <= fifo_last_buffer;

      case (state)
        IDLE: begin
          // When FIFO is ready, initiate a read operation.
          if (i_block_fifo_rdy) begin
            o_block_fifo_act <= 1'b1;    // Assert FIFO activate signal
            // Capture FIFO data: assume the MSB of i_block_fifo_data is the "last" flag,
            // and the lower DATA_WIDTH bits are the data.
            fifo_data_buffer <= i_block_fifo_data[DATA_WIDTH-1:0];
            fifo_last_buffer <= i_block_fifo_data[DATA_WIDTH];
            fifo_valid_buffer<= 1'b1;
            o_block_fifo_stb <= 1'b1;    // Pulse to indicate FIFO data has been read
            state            <= DATA_LOADED;
          end
        end

        DATA_LOADED: begin
          // Transfer data to AXI interface only when AXI is ready.
          if (i_axi_ready) begin
            o_axi_valid <= 1'b1;         // Assert AXI valid signal
            // o_axi_data and o_axi_last are driven from the internal buffers.
            fifo_valid_buffer<= 1'b0;    // Clear the buffer after transfer
            state            <= IDLE;
          end
          // If AXI is not ready, hold the data in the buffer (state remains DATA_LOADED)
        end

      endcase
    end
  end

endmodule