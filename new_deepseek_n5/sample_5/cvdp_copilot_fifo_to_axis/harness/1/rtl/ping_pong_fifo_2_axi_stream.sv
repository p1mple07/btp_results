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

// Internal signals
logic [DATA_WIDTH - 1:0] fifo_data_buffer;
logic fifo_valid_buffer;
logic fifo_last_buffer;

// Reset Condition
always_ff @(posedge i_axi_clk or posedge rst) begin
  if (rst) begin
    o_block_fifo_act   <= 1'b0;
    o_axi_valid        <= 1'b0;
    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
  else begin
    case (i_block_fifo_rdy, i_axi_ready)
    // If FIFO not ready, AXI remains inactive
    when (0, 1)
      o_axi_valid <= 1'b0;
    // If AXI not ready, AXI remains inactive
    when (1, 0)
      o_axi_valid <= 1'b0;
    // If both ready, transfer data
    default
      o_axi_data <= fifo_data_buffer;
      o_axi_last <= 1'b1;
      o_axi_valid <= 1'b1;
      fifo_data_buffer <= {DATA_WIDTH{1'b0}};
      fifo_valid_buffer <= 1'b0;
      fifo_last_buffer <= 1'b0;
  endcase
end