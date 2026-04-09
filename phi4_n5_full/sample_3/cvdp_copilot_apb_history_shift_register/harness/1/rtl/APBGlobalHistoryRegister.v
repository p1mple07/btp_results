module APBGlobalHistoryRegister (
  input  wire         pclk,            // APB clock
  input  wire         presetn,         // Asynchronous active-low reset
  input  wire [9:0]   paddr,           // APB address bus (10 bits)
  input  wire         pselx,           // APB select signal
  input  wire         penable,         // APB enable signal
  input  wire         pwrite,          // APB write enable (1 = write)
  input  wire [7:0]   pwdata,          // APB write data bus
  output reg          pready,          // APB ready signal
  output reg [7:0]    prdata,          // APB read data bus
  output reg          pslverr,         // APB error signal (invalid address)
  input  wire         history_shift_valid, // Clock to update history register
  input  wire         clk_gate_en,     // Clock gating enable (domain of pclk)
  output wire         history_full,    // Asserted if predict_history == 8'hFF
  output wire         history_empty,   // Asserted if predict_history == 8'h00
  output reg          error_flag,      // Latched error flag for invalid address
  output wire         interrupt_full,  // Interrupt when history_full is set
  output wire         interrupt_error  // Interrupt when error_flag is set
);

  //-------------------------------------------------------------------------
  // Internal Registers
  //-------------------------------------------------------------------------
  reg [7:0] control_register;  // CSR at address 0x0
  reg [7:0] train_history;     // CSR at address 0x1 (only lower 7 bits used)
  reg [7:0] predict_history;   // Global history shift register (CSR at 0x2, read-only)

  //-------------------------------------------------------------------------
  // Clock Gating Cell: Generate a gated clock from pclk using clk_gate_en.
  // The gated clock toggles only on the negative edge of pclk when clk_gate_en is high.
  //-------------------------------------------------------------------------
  reg clk_gated;
  always @(negedge pclk) begin
    if (clk_gate_en)
      clk_gated <= ~clk_gated;
    else
      clk_gated <= 1'b0;
  end
  wire gated_clk = clk_gated;

  //-------------------------------------------------------------------------
  // APB Interface: Handle register read/write operations on the gated clock.
  //-------------------------------------------------------------------------
  always @(posedge gated_clk or negedge presetn) begin
    if (!presetn) begin
      control_register <= 8'b0;
      train_history    <= 8'b0;
      prdata           <= 8'b0;
      pslverr          <= 1'b0;
      pready           <= 1'b0;
    end else begin
      if (pselx && penable) begin
        if (pwrite) begin
          // Write operations: Only control_register and train_history are writable.
          case(paddr)
            10'h000: control_register <= pwdata;
            10'h001: train_history    <= pwdata;
            default: pslverr          <= 1'b1; // Invalid address
          endcase
        end else begin
          // Read operations: Return register values based on address.
          case(paddr)
            10'h000: prdata <= control_register;
            10'h001: prdata <= {1'b0, train_history[6:0]};  // Reserved bit 7 = 0
            10'h002: prdata <= predict_history;              // Read-only history
            default: begin
                      pslverr <= 1'b1;
                      prdata  <= 8'b0;
                    end
          endcase
        end
        pready <= 1'b1;
      end else begin
        pready <= 1'b0;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Error Flag Update: Latch an error if an invalid address is accessed.
  //-------------------------------------------------------------------------
  always @(posedge gated_clk or negedge presetn) begin
    if (!presetn)
      error_flag <= 1'b0;
    else if (pselx && penable) begin
      // Valid addresses: 0x0, 0x1, and 0x2.
      if (paddr == 10'h000 || paddr == 10'h001 || paddr == 10'h002)
        error_flag <= 1'b0;
      else
        error_flag <= 1'b1;
    end
  end

  //-------------------------------------------------------------------------
  // History Shift Register Update: Update predict_history on the rising edge
  // of history_shift_valid. Misprediction takes precedence over normal update.
  //-------------------------------------------------------------------------
  always @(posedge history_shift_valid or negedge presetn) begin
    if (!presetn)
      predict_history <= 8'b0;
    else if (control_register[2] == 1'b1) begin
      // Misprediction handling: Load history with [train_history (7 bits), train_taken (bit 3)]
      predict_history <= {train_history[6:0], control_register[3]};
    end else if (control_register[0] == 1'b1) begin
      // Normal update: Shift left and insert predict_taken (bit 1) as LSB.
      predict_history <= {predict_history[6:0], control_register[1]};
    end else begin
      // No valid update; retain current state.
      predict_history <= predict_history;
    end
  end

  //-------------------------------------------------------------------------
  // Status & Interrupt Signals (Combinational)
  //-------------------------------------------------------------------------
  assign history_full   = (predict_history == 8'hFF);
  assign history_empty  = (predict_history == 8'h00);
  assign interrupt_full = history_full;
  assign interrupt_error= error_flag;

endmodule