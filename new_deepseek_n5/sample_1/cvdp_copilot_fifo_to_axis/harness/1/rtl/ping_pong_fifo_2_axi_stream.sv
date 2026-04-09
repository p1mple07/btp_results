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
state machine_state;

// Reset Condition
always_ff @(posedge i_axi_clk or posedge rst) begin
  if (rst) begin
    o_block_fifo_act   <= 1'b0;
    o_axi_valid        <= 1'b0;
    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
    machine_state = IDLE;
  end else begin
    case (machine_state)
      IDLE:
        if (i_axi_ready && i_block_fifo_rdy) begin
          // Send data to AXI
          o_axi_user <= i_axi_user;
          o_axi_valid <= 1'b1;
          o_axi_last <= fifo_last_buffer;
          o_axi_data <= fifo_data_buffer;
          machine_state = DATA;
        end else begin
          // AXI not ready or FIFO not ready
          o_axi_valid <= 0;
          o_axi_last <= 0;
          o_axi_data <= 0;
          o_block_fifo_act <= 0;
          o_block_fifo_data <= 0;
          o_block_fifo_stb <= 0;
          machine_state = IDLE;
        end
      DATA:
        // Send data and update state
        o_axi_user <= i_axi_user;
        o_axi_valid <= 1'b1;
        o_axi_last <= fifo_last_buffer;
        o_axi_data <= fifo_data_buffer;
        machine_state = IDLE;
        fifo_valid_buffer <= 1'b0;
        fifo_last_buffer <= 0;
    endcase
  end
end