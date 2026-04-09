module sync_serial_communication_tx_rx(
    input  clk,
    input  reset_n,
    input  [2:0] sel,
    input  [63:0] data_in,
    output [63:0] data_out,
    output done
);

  //-------------------------------------------------------------------------
  // Instantiate TX block (optimized)
  //-------------------------------------------------------------------------
  wire tx_out;
  wire tx_done;
  wire serial_clk_in;

  tx_block uut_tx_block (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .sel(sel),
      .serial_out(tx_out),
      .done(tx_done),
      .serial_clk(serial_clk_in)
  );

  //-------------------------------------------------------------------------
  // 3-stage pipeline between TX and RX blocks
  // (Increases overall latency by 3 cycles and reduces combinational load)
  //-------------------------------------------------------------------------
  reg tx_out_p1, tx_out_p2, tx_out_p3;
  reg serial_clk_p1, serial_clk_p2, serial_clk_p3;
  reg tx_done_p1, tx_done_p2, tx_done_p3;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      tx_out_p1   <= 1'b0;
      tx_out_p2   <= 1'b0;
      tx_out_p3   <= 1'b0;
      serial_clk_p1 <= 1'b0;
      serial_clk_p2 <= 1'b0;
      serial_clk_p3 <= 1'b0;
      tx_done_p1  <= 1'b0;
      tx_done_p2  <= 1'b0;
      tx_done_p3  <= 1'b0;
    end else begin
      tx_out_p1   <= tx_out;
      tx_out_p2   <= tx_out_p1;
      tx_out_p3   <= tx_out_p2;
      serial_clk_p1 <= serial_clk_in;
      serial_clk_p2 <= serial_clk_p1;
      serial_clk_p3 <= serial_clk_p2;
      tx_done_p1  <= tx_done;
      tx_done_p2  <= tx_done_p1;
      tx_done_p3  <= tx_done_p2;
    end
  end

  //-------------------------------------------------------------------------
  // Instantiate RX block (optimized)
  //-------------------------------------------------------------------------
  rx_block uut_rx_block (
      .clk(clk),
      .serial_clk(serial_clk_p3),
      .reset_n(reset_n),
      .sel(sel),
      .data_in(tx_out_p3),
      .data_out(data_out),
      .done(done)
  );

endmodule

//------------------------------------------------------------------------------
// Optimized TX Block
//------------------------------------------------------------------------------
module tx_block(
    input  clk,
    input  reset_n,
    input  [63:0] data_in,
    input  [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk
);

  // Internal registers
  reg [63:0] data_reg;
  reg [6:0]  bit_count;
  reg [6:0]  reg_count;
  reg [6:0]  temp_reg_count;

  // Combined sequential logic: state update, data shifting, and output generation.
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      data_reg      <= 64'h0;
      bit_count     <= 7'h0;
      reg_count     <= 7'h0;
      temp_reg_count<= 7'h0;
      serial_out    <= 1'b0;
      done          <= 1'b0;
    end else begin
      if (done) begin
        // Select data width based on sel; reset bit_count when done.
        case (sel)
          3'b000: begin
            data_reg  <= 64'h0;
            bit_count <= 7'd0;
          end
          3'b001: begin
            data_reg  <= {56'h0, data_in[7:0]};
            bit_count <= 7'd7;
          end
          3'b010: begin
            data_reg  <= {48'h0, data_in[15:0]};
            bit_count <= 7'd15;
          end
          3'b011: begin
            data_reg  <= {32'h0, data_in[31:0]};
            bit_count <= 7'd31;
          end
          3'b100: begin
            data_reg  <= data_in;
            bit_count <= 7'd63;
          end
          default: begin
            data_reg  <= 64'h0;
            bit_count <= 7'h0;
          end
        endcase
      end else if (bit_count > 7'h0) begin
        // Shift out one bit per cycle.
        data_reg   <= data_reg >> 1;
        bit_count  <= bit_count - 1;
      end
      // Update reg_count and pipeline register for clock gating.
      reg_count     <= bit_count;
      temp_reg_count<= reg_count;
      // Drive serial_out with LSB of data_reg when active.
      serial_out    <= ((reg_count != 7'h0) || (bit_count != 7'h0)) ? data_reg[0] : 1'b0;
      // Assert done when all bits have been transmitted.
      done          <= (bit_count == 7'h0) ? 1'b1 : 1'b0;
    end
  end

  // Generate serial clock with minimal combinational logic.
  // The #1 delay is retained for simulation purposes.
  assign #1 serial_clk = clk && (temp_reg_count !== 7'd0);

endmodule

//------------------------------------------------------------------------------
// Optimized RX Block
//------------------------------------------------------------------------------
module rx_block(
    input  wire clk,
    input  wire reset_n,
    input  wire data_in,
    input  wire serial_clk,
    input  wire [2:0] sel,
    output reg done,
    output reg [63:0] data_out
);

  // Internal registers for serial data capture.
  reg [63:0] data_reg;
  reg [7:0]  bit_count;
  reg [7:0]  count;

  // Capture serial data on rising edge of serial_clk.
  always @(posedge serial_clk or negedge reset_n) begin
    if (!reset_n) begin
      data_reg  <= 64'h0;
      bit_count <= 8'd0;
    end else if (done) begin
      // Reset on completion.
      data_reg  <= 64'h0;
      bit_count <= 8'd0;
    end else begin
      // Shift in the new bit at the current index.
      data_reg[bit_count] <= data_in;
      bit_count <= bit_count + 1;
    end
  end

  // Monitor reception progress and update outputs on clk edge.
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      count    <= 8'd0;
      done     <= 1'b0;
      data_out <= 64'h0;
    end else if (bit_count != 0) begin
      if (count < bit_count) begin
        count <= count + 1;
        done  <= 1'b0;
      end else begin
        // Once all bits are received, latch the output.
        count  <= count;  // Hold count
        done   <= 1'b1;
        case (sel)
          3'b000: data_out <= 64'h0;
          3'b001: data_out <= {56'h0, data_reg};
          3'b010: data_out <= {48'h0, data_reg};
          3'b011: data_out <= {32'h0, data_reg};
          3'b100: data_out <= data_reg;
          default: data_out <= 64'h0;
        endcase
      end
    end else begin
      // No data received: reset counters.
      count <= 8'd0;
      done  <= 1'b0;
    end
  end

endmodule