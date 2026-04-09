module APBGlobalHistoryRegister (
  input  wire         pclk,          // APB clock
  input  wire         presetn,       // Asynchronous reset (active-low)
  input  wire [9:0]   paddr,         // APB address bus (10 bits)
  input  wire         pselx,         // APB select signal
  input  wire         penable,       // APB enable signal
  input  wire         pwrite,        // APB write enable (high for writes)
  input  wire [7:0]   pwdata,        // APB write data
  output reg          pread,         // APB ready signal
  output reg [7:0]    prdata,        // APB read data
  output reg          pslverr,       // APB error signal (invalid address)
  input  wire         history_shift_valid, // Signal to update predict_history
  input  wire         clk_gate_en,   // Clock gating enable (in pclk domain)
  output wire         history_full,  // Asserted if predict_history == 8'hFF
  output wire         history_empty,// Asserted if predict_history == 8'h00
  output reg          error_flag,    // Latched error flag (from pslverr)
  output wire         interrupt_full,// Interrupt when history_full is set
  output wire         interrupt_error// Interrupt when error_flag is set
);

  //-------------------------------------------------------------------------
  // Internal Registers
  //-------------------------------------------------------------------------
  reg [7:0] control_register;  // Address 0x0: Bit0 = predict_valid, Bit1 = predict_taken,
                               // Bit2 = train_mispredicted, Bit3 = train_taken, Bits7:4 reserved.
  reg [7:0] train_history;     // Address 0x1: 7-bit history (bits6:0), bit7 reserved.
  reg [7:0] predict_history;   // Address 0x2: 8-bit branch history shift register (read-only via APB)

  //-------------------------------------------------------------------------
  // Gated Clock for APB operations
  //-------------------------------------------------------------------------
  // clk_gate_en is assumed to toggle only on the negative edge of pclk to avoid glitches.
  wire gated_clk = pclk & clk_gate_en;

  //-------------------------------------------------------------------------
  // APB Interface Logic
  //-------------------------------------------------------------------------
  // This always block handles APB transactions (read/write) and updates
  // control_register, train_history, and prdata, pread, pslverr.
  always @(posedge gated_clk or negedge presetn) begin
    if (!presetn) begin
      control_register  <= 8'b0;
      train_history     <= 8'b0;
      predict_history   <= 8'b0;
      pread             <= 1'b0;
      pslverr           <= 1'b0;
      prdata            <= 8'b0;
      error_flag        <= 1'b0;
    end else begin
      // Default assignments: no transaction active.
      pread  <= 1'b0;
      pslverr<= 1'b0;
      
      // Check if an APB transaction is active.
      if (pselx && penable) begin
        if (pwrite) begin
          // Write operation: update registers based on address.
          case (paddr[7:0])
            8'h00: control_register <= pwdata;
            8'h01: train_history    <= pwdata; // Only lower 7 bits are used.
            8'h02: ;                 // Read-only register; ignore write.
            default: pslverr       <= 1'b1;
          endcase
        end else begin
          // Read operation: drive prdata based on address.
          case (paddr[7:0])
            8'h00: prdata <= control_register;
            8'h01: prdata <= train_history;
            8'h02: prdata <= predict_history;
            default: pslverr <= 1'b1;
          endcase
          pread <= 1'b1;
        end
      end
      
      // Latch error flag to reflect any invalid address access.
      error_flag <= pslverr;
    end
  end

  //-------------------------------------------------------------------------
  // Predict History Update Logic
  //-------------------------------------------------------------------------
  // The predict_history register is updated on the rising edge of history_shift_valid.
  // Mispredictions have highest priority.
  always @(posedge history_shift_valid or negedge presetn) begin
    if (!presetn) begin
      predict_history <= 8'b0;
    end else begin
      if (control_register[2]) begin
        // Misprediction: load the history with the recorded train_history (7 bits)
        // concatenated with the actual outcome (train_taken in bit3).
        predict_history <= { train_history[6:0], control_register[3] };
      end else if (control_register[0]) begin
        // Normal update: shift in the predicted outcome (predict_taken in bit1)
        // into the least significant bit.
        predict_history <= { predict_history[6:0], control_register[1] };
      end else begin
        // No valid prediction; retain the current history.
        predict_history <= predict_history;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Status & Interrupt Signals
  //-------------------------------------------------------------------------
  // history_full is asserted when predict_history is all ones.
  assign history_full   = (predict_history == 8'hFF);
  // history_empty is asserted when predict_history is all zeros.
  assign history_empty  = (predict_history == 8'h00);
  // interrupt_full directly reflects history_full.
  assign interrupt_full = history_full;
  // interrupt_error directly reflects error_flag.
  assign interrupt_error= error_flag;

endmodule