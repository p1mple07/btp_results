Module: tx_block
// Description: Serializes parallel data based on the sel input.
//              Supports 8, 16, 32, or 64-bit transmission.
//              Generates a serial_out and a gated serial_clk.
//-----------------------------------------------------------------
module tx_block (
  input  logic         clk,
  input  logic         reset_n,
  input  logic [63:0]  data_in,
  input  logic [2:0]   sel,
  output logic         serial_out,
  output logic         done,
  output logic         serial_clk
);

  // State encoding: 0 = IDLE, 1 = TX
  logic state;
  // Bit counter (max 64 bits)
  logic [5:0] bit_count;
  // Shift register for serialization (only lower bits used)
  logic [63:0] shift_reg;
  // Computed bit width based on sel input
  logic [5:0] bit_width;

  // Determine bit_width based on sel.
  // Valid cases: 3'h1 -> 8, 3'h2 -> 16, 3'h3 -> 32, 3'h4 -> 64.
  // For sel==3'h0 or any other value, bit_width = 0 (no transmission).
  always_comb begin
    case (sel)
      3'h0, default: bit_width = 6'd0;
      3'h1: bit_width = 6'd8;
      3'h2: bit_width = 6'd16;
      3'h3: bit_width = 6'd32;
      3'h4: bit_width = 6'd64;
    endcase
  end

  // State machine for transmission.
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state         <= 1'b0;
      bit_count     <= 6'd0;
      shift_reg     <= 64'd0;
      done          <= 1'b0;
    end
    else begin
      case (state)
        1'b0: begin  // IDLE state
          done <= 1'b0;
          // Only start transmission if a valid data width is selected.
          if (bit_width != 6'd0) begin
            // Load the appropriate bits from data_in.
            case (sel)
              3'h1: shift_reg <= data_in[7:0];
              3'h2: shift_reg <= data_in[15:0];
              3'h3: shift_reg <= data_in[31:0];
              3'h4: shift_reg <= data_in;
              default: shift_reg <= 64'd0;
            endcase
            // Initialize bit counter (number of shifts required)
            bit_count <= bit_width - 6'd1;
            state     <= 1'b1;  // Move to TX state
          end
        end
        1'b1: begin  // TX state: shifting out bits
          // Output the LSB of the shift register.
          serial_out <= shift_reg[0];
          // Shift right by one bit.
          shift_reg  <= shift_reg >> 1;
          if (bit_count == 6'd0) begin
            // Transmission complete; assert done for one cycle.
            done <= 1'b1;
            state <= 1'b0;  // Return to IDLE
          end
          else begin
            bit_count <= bit_count - 6'd1;
            done      <= 1'b0;
          end
        end
      endcase
    end
  end

  // Generate serial_clk: when transmitting, use clk; otherwise, hold low.
  assign serial_clk = (state) ? clk : 1'b0;

endmodule


//-----------------------------------------------------------------
// Module: rx_block
// Description: Captures incoming serial data (data_in) and
//              reconstructs it into a 64-bit parallel output (data_out)
//              based on the sel input.
//              Supports 8, 16, 32, or 64-bit reception.
//-----------------------------------------------------------------
module rx_block (
  input  logic         clk,
  input  logic         reset_n,
  input  logic         data_in,     // Serialized data from transmitter.
  input  logic [2:0]   sel,
  input  logic         serial_clk,  // Clock used for sampling serial data.
  output logic [63:0]  data_out,
  output logic         done
);

  // State encoding: 0 = IDLE, 1 = RX
  logic state;
  // Bit counter (max 64 bits)
  logic [5:0] bit_count;
  // Shift register for receiving bits (accumulates LSB-first).
  logic [63:0] shift_reg;
  // Computed bit width based on sel input.
  logic [5:0] bit_width;

  // Determine bit_width based on sel.
  always_comb begin
    case (sel)
      3'h0, default: bit_width = 6'd0;
      3'h1: bit_width = 6'd8;
      3'h2: bit_width = 6'd16;
      3'h3: bit_width = 6'd32;
      3'h4: bit_width = 6'd64;
    endcase
  end

  // State machine for reception, triggered by serial_clk.
  always_ff @(posedge serial_clk or negedge reset_n) begin
    if (!reset_n) begin
      state         <= 1'b0;
      bit_count     <= 6'd0;
      shift_reg     <= 64'd0;
      data_out      <= 64'd0;
      done          <= 1'b0;
    end
    else begin
      case (state)
        1'b0: begin  // IDLE state
          done <= 1'b0;
          if (bit_width != 6'd0) begin
            // Initialize shift register and bit counter.
            shift_reg    <= 64'd0;
            bit_count    <= bit_width - 6'd1;
            state        <= 1'b1;  // Move to RX state
          end
        end
        1'b1: begin  // RX state: capturing bits
          // Shift left and insert the new bit at LSB.
          // This accumulates bits in LSB-first order.
          shift_reg <= {shift_reg[63:1], data_in};
          if (bit_count == 6'd0) begin
            // Reception complete; assign received data to data_out.
            data_out  <= shift_reg;
            done      <= 1'b1;  // Assert done for one cycle.
            state     <= 1'b0;  // Return to IDLE
          end
          else begin
            bit_count <= bit_count - 6'd1;
            done      <= 1'b0;
          end
        end
      endcase
    end
  end

endmodule


//-----------------------------------------------------------------
// Top-Level Module: sync_serial_communication_top
// Description: Integrates the tx_block and rx_block modules.
//              Connects the transmitter's serial outputs to the
//              receiver's serial inputs.
//-----------------------------------------------------------------
module sync_serial_communication_top (
  input  logic         clk,
  input  logic         reset_n,
  input  logic [63:0]  data_in,  // Data to be transmitted.
  input  logic [2:0]   sel,      // Controls the data width for TX.
  output logic [63:0]  data_out, // Reconstructed data from RX.
  output logic         done      // Indicates valid output from RX.
);

  // Wires between modules.
  wire serial_out;
  wire tx_done;      // Not used externally.
  wire serial_clk;

  // Instantiate the transmitter block.
  tx_block u_tx (
    .clk        (clk),
    .reset_n    (reset_n),
    .data_in    (data_in),
    .sel        (sel),
    .serial_out (serial_out),
    .done       (tx_done),
    .serial_clk (serial_clk)
  );

  // Instantiate the receiver block.
  rx_block u_rx (
    .clk          (clk),
    .reset_n      (reset_n),
    .data_in      (serial_out), // Connect transmitter's serial_out.
    .sel          (sel),
    .serial_clk   (serial_clk),
    .data_out     (data_out),
    .done         (done)
  );

endmodule