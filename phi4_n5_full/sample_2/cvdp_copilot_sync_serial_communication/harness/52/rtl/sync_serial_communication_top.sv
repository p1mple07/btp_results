module sync_serial_communication_tx_rx(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [2:0]  sel,
    input  wire [63:0] data_in,
    output wire [63:0] data_out,
    output wire        done
);

  // Internal wires connecting TX and RX blocks
  wire tx_out;
  wire tx_done;
  wire serial_clk_in;

  // Instantiate TX block
  tx_block uut_tx_block (
      .clk        (clk),
      .reset_n    (reset_n),
      .data_in    (data_in),
      .sel        (sel),
      .serial_out (tx_out),
      .done       (tx_done),
      .serial_clk (serial_clk_in)
  );

  // Instantiate RX block
  rx_block uut_rx_block (
      .clk        (clk),
      .reset_n    (reset_n),
      .data_in    (tx_out),
      .serial_clk (serial_clk_in),
      .sel        (sel),
      .data_out   (data_out),
      .done       (done)
  );

endmodule

// Optimized TX block with combined sequential logic and 3-cycle pipelining
module tx_block(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [63:0] data_in,
    input  wire [2:0]  sel,
    output wire        serial_out,
    output wire        done,
    output wire        serial_clk
);

  // State registers for TX state machine
  reg [63:0] data_reg;
  reg [6:0]  bit_count;
  reg [6:0]  reg_count;
  reg [6:0]  temp_reg_count;
  reg        serial_out_reg;
  reg        done_reg;

  // Combined always block: state update, shifting, and output logic
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      data_reg      <= 64'd0;
      bit_count     <= 7'd0;
      reg_count     <= 7'd0;
      temp_reg_count<= 7'd0;
      serial_out_reg<= 1'b0;
      done_reg      <= 1'b0;
    end else begin
      if (done_reg) begin
        // Reconfigure on completion based on 'sel'
        case (sel)
          3'b000: begin
            data_reg <= 64'd0;
            bit_count<= 7'd0;
          end
          3'b001: begin
            data_reg <= {56'd0, data_in[7:0]};
            bit_count<= 7'd7;
          end
          3'b010: begin
            data_reg <= {48'd0, data_in[15:0]};
            bit_count<= 7'd15;
          end
          3'b011: begin
            data_reg <= {32'd0, data_in[31:0]};
            bit_count<= 7'd31;
          end
          3'b100: begin
            data_reg <= data_in;
            bit_count<= 7'd63;
          end
          default: begin
            data_reg <= 64'd0;
            bit_count<= 7'd0;
          end
        endcase
      end else if (bit_count > 7'd0) begin
        // Shift data and decrement bit count
        data_reg  <= data_reg >> 1;
        bit_count <= bit_count - 1;
      end
      reg_count    <= bit_count;
      temp_reg_count<= reg_count;
      serial_out_reg<= (reg_count != 7'd0 || bit_count != 7'd0) ? data_reg[0] : 1'b0;
      done_reg     <= (bit_count == 7'd0) ? 1'b1 : 1'b0;
    end
  end

  // 3-stage pipeline registers for TX outputs and serial clock
  reg serial_out_stage1, serial_out_stage2, serial_out_stage3;
  reg done_stage1, done_stage2, done_stage3;
  reg serial_clk_stage1, serial_clk_stage2, serial_clk_stage3;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      serial_out_stage1 <= 1'b0;
      serial_out_stage2 <= 1'b0;
      serial_out_stage3 <= 1'b0;
      done_stage1       <= 1'b0;
      done_stage2       <= 1'b0;
      done_stage3       <= 1'b0;
      serial_clk_stage1 <= 1'b0;
      serial_clk_stage2 <= 1'b0;
      serial_clk_stage3 <= 1'b0;
    end else begin
      serial_out_stage1 <= serial_out_reg;
      serial_out_stage2 <= serial_out_stage1;
      serial_out_stage3 <= serial_out_stage2;
      done_stage1       <= done_reg;
      done_stage2       <= done_stage1;
      done_stage3       <= done_stage2;
      // Generate and pipeline serial clock signal (gated by temp_reg_count)
      serial_clk_stage1 <= (temp_reg_count != 7'd0) ? clk : 1'b0;
      serial_clk_stage2 <= serial_clk_stage1;
      serial_clk_stage3 <= serial_clk_stage2;
    end
  end

  assign serial_out = serial_out_stage3;
  assign done       = done_stage3;
  assign serial_clk = serial_clk_stage3;

endmodule

// Optimized RX block with combined sequential logic and 3-cycle pipelining
module rx_block(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        data_in,
    input  wire        serial_clk,
    input  wire [2:0]  sel,
    output wire        done,
    output wire [63:0] data_out
);

  // State registers for RX state machine
  reg [63:0] data_reg;
  reg [7:0]  bit_count;
  reg [7:0]  count;
  reg        serial_clk_d;
  reg        rx_done;
  reg [63:0] rx_data_out;

  // Combined always block: capture serial data on rising edge of serial_clk and update counters
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      serial_clk_d   <= 1'b0;
      data_reg       <= 64'd0;
      bit_count      <= 8'd0;
      count          <= 8'd0;
      rx_done        <= 1'b0;
      rx_data_out    <= 64'd0;
    end else begin
      serial_clk_d   <= serial_clk;
      // Rising edge detection for serial_clk
      if (serial_clk && !serial_clk_d) begin
        data_reg <= {data_reg[62:0], data_in};
        bit_count<= bit_count + 1;
      end
      if (bit_count != 8'd0) begin
        count <= count + 1;
        if (count >= bit_count) begin
          rx_done <= 1'b1;
          case (sel)
            3'b000: rx_data_out <= 64'd0;
            3'b001: rx_data_out <= {56'd0, data_reg[7:0]};
            3'b010: rx_data_out <= {48'd0, data_reg[15:0]};
            3'b011: rx_data_out <= {32'd0, data_reg[31:0]};
            3'b100: rx_data_out <= data_reg;
            default: rx_data_out <= 64'd0;
          endcase
        end else begin
          rx_done <= 1'b0;
        end
      end else begin
        count <= 8'd0;
        rx_done <= 1'b0;
      end
    end
  end

  // 3-stage pipeline registers for RX outputs
  reg rx_done_stage1, rx_done_stage2, rx_done_stage3;
  reg [63:0] rx_data_out_stage1, rx_data_out_stage2, rx_data_out_stage3;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      rx_done_stage1       <= 1'b0;
      rx_done_stage2       <= 1'b0;
      rx_done_stage3       <= 1'b0;
      rx_data_out_stage1   <= 64'd0;
      rx_data_out_stage2   <= 64'd0;
      rx_data_out_stage3   <= 64'd0;
    end else begin
      rx_done_stage1       <= rx_done;
      rx_done_stage2       <= rx_done_stage1;
      rx_done_stage3       <= rx_done_stage2;
      rx_data_out_stage1   <= rx_data_out;
      rx_data_out_stage2   <= rx_data_out_stage1;
      rx_data_out_stage3   <= rx_data_out_stage2;
    end
  end

  assign done     = rx_done_stage3;
  assign data_out = rx_data_out_stage3;

endmodule