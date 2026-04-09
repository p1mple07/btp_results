module ping_pong_fifo_2_axi_stream #(
  parameter logic DATA_WIDTH          = 24,
  parameter logic STROBE_WIDTH        = DATA_WIDTH / 8,
  parameter logic USE_KEEP            = 0,
  parameter logic USER_IN_DATA        = 1
)(
  input  logic                         rst,

  // Ping Pong FIFO Read Interface
  input  logic                         i_block_fifo_rdy,
  output logic                         o_block_fifo_act,
  input  logic [23:0]                  i_block_fifo_size,
  // i_block_fifo_data is assumed to be (DATA_WIDTH+1) bits wide,
  // with the MSB (bit DATA_WIDTH) representing the "last" flag and
  // the lower DATA_WIDTH bits carrying the actual data.
  input  logic [(DATA_WIDTH + 1) - 1:0] i_block_fifo_data,
  output logic                         o_block_fifo_stb,
  input  logic [3:0]                   i_axi_user,

  // AXI Stream Output
  input  logic                         i_axi_clk,
  output logic [3:0]                   o_axi_user,
  input  logic                         i_axi_ready,
  output logic [DATA_WIDTH - 1:0]      o_axi_data,
  output logic                         o_axi_last,
  output logic                         o_axi_valid
);

  // Internal signals for buffering FIFO data
  logic [DATA_WIDTH - 1:0] fifo_data_buffer;
  logic                    fifo_valid_buffer;
  logic                    fifo_last_buffer;

  // For this example, we simply pass through the user signals.
  assign o_axi_user = i_axi_user;

  // Reset and transfer logic: The module is clocked by i_axi_clk.
  // It captures data from the FIFO only if there is no pending transfer,
  // and drives the AXI interface only when data is available and i_axi_ready is asserted.
  always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
      o_block_fifo_act   <= 1'b0;
      o_axi_valid        <= 1'b0;
      fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
      fifo_valid_buffer  <= 1'b0;
      fifo_last_buffer   <= 1'b0;
      o_block_fifo_stb   <= 1'b0;
    end
    else begin
      // FIFO read logic: Only capture new FIFO data if there is no pending transfer.
      // When FIFO is ready (i_block_fifo_rdy) and no data is buffered, assert the FIFO
      // activate signal and capture the data and last flag.
      if (!fifo_valid_buffer && i_block_fifo_rdy) begin
        o_block_fifo_act <= 1'b1;
        // Capture FIFO data:
        // - fifo_data_buffer gets the lower DATA_WIDTH bits (actual data).
        // - fifo_last_buffer gets the MSB (the "last" flag).
        fifo_data_buffer  <= i_block_fifo_data[DATA_WIDTH - 1:0];
        fifo_last_buffer  <= i_block_fifo_data[DATA_WIDTH];
        fifo_valid_buffer <= 1'b1;
        o_block_fifo_stb  <= 1'b1; // Pulse strobe to indicate a FIFO read.
      end
      else begin
        o_block_fifo_act <= 1'b0;
        o_block_fifo_stb <= 1'b0;
      end

      // AXI Stream transfer logic: If there is buffered data and the AXI interface is ready,
      // drive the AXI outputs and clear the buffer.
      if (fifo_valid_buffer && i_axi_ready) begin
        o_axi_data   <= fifo_data_buffer;
        o_axi_last   <= fifo_last_buffer;
        o_axi_valid  <= 1'b1;
        fifo_valid_buffer <= 1'b0; // Clear buffer after successful transfer.
      end
      else begin
        // If no valid data or AXI is not ready, drive AXI outputs low.
        o_axi_valid  <= 1'b0;
        o_axi_data   <= {DATA_WIDTH{1'b0}};
        o_axi_last   <= 1'b0;
      end
    end
  end

endmodule