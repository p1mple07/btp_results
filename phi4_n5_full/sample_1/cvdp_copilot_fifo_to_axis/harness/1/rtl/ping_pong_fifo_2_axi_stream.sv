module ping_pong_fifo_2_axi_stream #(
  parameter logic DATA_WIDTH       = 24,
  parameter logic STROBE_WIDTH     = DATA_WIDTH / 8,
  parameter logic USE_KEEP         = 0,
  parameter logic USER_IN_DATA     = 1
)(
  input  logic                  rst,

  // Ping Pong FIFO Read Interface
  input  logic                  i_block_fifo_rdy,
  output logic                  o_block_fifo_act,
  input  logic [23:0]           i_block_fifo_size,
  input  logic [(DATA_WIDTH+1)-1:0] i_block_fifo_data,
  output logic                  o_block_fifo_stb,
  input  logic [3:0]            i_axi_user,

  // AXI Stream Output
  input  logic                  i_axi_clk,
  output logic [3:0]            o_axi_user,
  input  logic                  i_axi_ready,
  output logic [DATA_WIDTH-1:0] o_axi_data,
  output logic                  o_axi_last,
  output logic                  o_axi_valid
);

  // Internal buffer signals
  logic [DATA_WIDTH-1:0] fifo_data_buffer;
  logic                  fifo_valid_buffer;
  logic                  fifo_last_buffer;

  // State machine states: IDLE and TRANSFER
  typedef enum logic {IDLE, TRANSFER} state_t;
  state_t state;

  // Pass through user signal if USER_IN_DATA is enabled; otherwise, drive constant 0.
  assign o_axi_user = (USER_IN_DATA) ? i_axi_user : 4'b0;

  // Synchronous state machine to manage FIFO read and AXI transfer
  always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
      state             <= IDLE;
      fifo_valid_buffer <= 1'b0;
      o_block_fifo_act  <= 1'b0;
      o_block_fifo_stb  <= 1'b0;
      o_axi_valid       <= 1'b0;
      o_axi_data        <= {DATA_WIDTH{1'b0}};
      o_axi_last        <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          if (i_block_fifo_rdy) begin
            // Assert FIFO activate and strobe, read data into buffer.
            o_block_fifo_act  <= 1'b1;
            fifo_data_buffer  <= i_block_fifo_data[DATA_WIDTH-1:0];
            fifo_last_buffer  <= i_block_fifo_data[DATA_WIDTH];
            o_block_fifo_stb  <= 1'b1;
            fifo_valid_buffer <= 1'b1;
            state             <= TRANSFER;
          end else begin
            o_block_fifo_act  <= 1'b0;
            o_block_fifo_stb  <= 1'b0;
            state             <= IDLE;
          end
        end

        TRANSFER: begin
          if (i_axi_ready) begin
            // Transfer buffered data to the AXI Stream interface.
            o_axi_valid  <= 1'b1;
            o_axi_data   <= fifo_data_buffer;
            o_axi_last   <= fifo_last_buffer;
            fifo_valid_buffer <= 1'b0;
            state        <= IDLE;
          end else begin
            // AXI not ready: hold the buffered data.
            o_axi_valid  <= 1'b0;
            state        <= TRANSFER;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule