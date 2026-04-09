module dma_xfer_engine (
    input wire clk,
    input wire rstn,
    input wire [3:0] addr,
    input wire we,
    input wire wd,
    input wire rd,
    input wire dma_req,
    input wire bus_grant,
    input wire rd_m,
    input wire bus_req,
    input wire bus_lock,
    input wire addr_m,
    input wire we_m,
    input wire wd_m,
    input wire size_m,
    output reg [31:0] bus_req_out
);

  // Internal state machine
  localparam IDLE = 2'd0;
  localparam WAIT_FOR_GRANT = 2'd1;
  localparam TR = 2'd2;
  reg state;

  // Internal signals
  reg [3:0] cnt;
  reg transfer_count;
  reg [31:0] return_data;

  // Control register fields
  localvar int src_reg;
  localvar int dest_reg;
  localvar int inc_src;
  localvar int inc_dst;
  localvar int inc_byte;
  localvar int inc_halfword;
  localvar int inc_word;

  // Clock and reset synchronization
  always @(posedge clk or posedge rstn) begin
    if (!rstn) begin
      state <= IDLE;
      src_reg <= 0;
      dest_reg <= 0;
      inc_src <= 0;
      inc_dst <= 0;
      inc_byte <= 0;
      inc_halfword <= 0;
      inc_word <= 0;
      return_data <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (dma_req) begin
            state <= WAIT_FOR_GRANT;
          end
        end

        WAIT_FOR_GRANT: begin
          if (bus_grant) begin
            state <= TR;
          end
        end

        TR: begin
          // Read from source address
          src_reg <= addr_m;
          // Shift data according to size encoding
          if (size_m == DMA_B) inc_byte = 1;
          else if (size_m == DMA_HW) inc_halfword = 1;
          else if (size_m == DMA_W) inc_word = 1;

          // Increment address
          addr_m <= addr + inc_byte * 8;

          // Write to destination address
          wd_m <= data;

          // Capture data into return_data
          return_data <= wd_m;

          // Increment transfer count
          cnt <= cnt + 1;

          // Check if transfer count is reached
          if (cnt == transfer_count) begin
            state <= IDLE;
          end
        end
      endcase
    end
  end

  // Output bus request
  assign bus_req_out = bus_req;

endmodule
