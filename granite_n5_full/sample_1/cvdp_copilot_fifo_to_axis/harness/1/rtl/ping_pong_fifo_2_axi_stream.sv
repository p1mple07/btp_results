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
  end else begin
    if (i_block_fifo_rdy &&!fifo_valid_buffer) begin
      o_block_fifo_act   <= 1'b1;
      o_axi_valid        <= 1'b1;
      fifo_data_buffer   <= i_block_fifo_data;
      fifo_valid_buffer  <= 1'b1;
      fifo_last_buffer   <= (i_block_fifo_size == 1)? 1'b1 : 1'b0;
    end else if (!i_block_fifo_rdy && fifo_valid_buffer) begin
      o_block_fifo_act   <= 1'b0;
      o_axi_valid        <= 1'b0;
    end else begin
      o_block_fifo_act   <= 1'b0;
      o_axi_valid        <= 1'b0;
    end

    if (o_axi_ready) begin
      fifo_valid_buffer  <= 1'b0;
      fifo_last_buffer   <= 1'b0;
    end
  end
end

assign o_axi_data     = fifo_data_buffer;
assign o_axi_last     = fifo_last_buffer;
assign o_axi_user     = i_axi_user;