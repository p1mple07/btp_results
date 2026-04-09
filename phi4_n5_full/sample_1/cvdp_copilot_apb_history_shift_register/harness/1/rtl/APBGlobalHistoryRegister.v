module APBGlobalHistoryRegister(
    input  wire         pclk,         // APB clock
    input  wire         presetn,      // Asynchronous reset (active low)
    input  wire [9:0]   paddr,        // Address bus (10 bits)
    input  wire         pselx,        // APB select signal
    input  wire         penable,      // APB enable signal
    input  wire         pwrite,       // Write enable: high for write, low for read
    input  wire [7:0]   pwdata,       // Write data bus
    output reg          pread,        // Ready signal (high during transaction)
    output reg [7:0]    prdata,       // Read data bus
    output reg          pslverr,      // Error signal (invalid address)
    output reg          history_full, // Asserted if predict_history == 8'hFF
    output reg          history_empty,// Asserted if predict_history == 8'h00
    output reg          error_flag,   // Indicates detected error (same as pslverr)
    output reg          interrupt_full, // Interrupt when history_full is set
    output reg          interrupt_error,// Interrupt when error_flag is set
    input  wire         history_shift_valid, // Trigger update of predict_history
    input  wire         clk_gate_en   // Clock gating enable signal
);

   // Internal registers for APB-accessible control registers
   reg [7:0] control_reg;         // Control register at address 0x0
   reg [7:0] train_history_reg;   // Train history register at address 0x1 (only lower 7 bits used)
   reg [7:0] predict_history_reg; // Global history shift register (read-only via APB at address 0x2)

   // Internal registers for APB transaction outputs
   reg [7:0] prdata_reg;
   reg       pslverr_reg;
   reg       apb_state;           // 0 = IDLE, 1 = WAIT (transaction in progress)

   // Gated clock generation: toggled on the negative edge of pclk when clk_gate_en is asserted.
   reg gated_clk;
   always @(negedge pclk) begin
       if (clk_gate_en)
           gated_clk <= ~gated_clk;
       else
           gated_clk <= pclk;
   end

   // APB state machine for handling read/write transactions.
   // In IDLE (apb_state = 0), pread is low.
   // When a valid transaction (pselx & penable) is detected, the state moves to WAIT (apb_state = 1)
   // and registers are updated; pread is driven high during the transaction.
   always @(posedge gated_clk or negedge presetn) begin
       if (!presetn) begin
           apb_state      <= 1'b0;
           prdata_reg     <= 8'b0;
           pslverr_reg    <= 1'b0;
       end else begin
           case (apb_state)
               1'b0: begin // IDLE state
                   if (pselx && penable)
                       apb_state <= 1'b1; // Start transaction
               end
               1'b1: begin // WAIT state: transaction in progress
                   if (!pselx || !penable) begin
                       // End of transaction; return to IDLE
                       apb_state <= 1'b0;
                   end else begin
                       // Process transaction
                       if (pwrite) begin
                           case (paddr)
                               10'h000: control_reg <= pwdata;         // Write to control_register
                               10'h001: train_history_reg <= {pwdata[6:0], 1'b0}; // Write to train_history (only lower 7 bits)
                               10'h002: ; // Cannot write to predict_history (read-only)
                               default: pslverr_reg <= 1'b1;            // Invalid address
                           endcase
                       end else begin
                           case (paddr)
                               10'h000: prdata_reg <= control_reg;         // Read control_register
                               10'h001: prdata_reg <= {train_history_reg[6:0], 1'b0}; // Read train_history
                               10'h002: prdata_reg <= predict_history_reg;    // Read predict_history
                               default: begin
                                   prdata_reg <= 8'b0;
                                   pslverr_reg <= 1'b1;                   // Invalid address
                               end
                           endcase
                       end
                   end
               end
           endcase
       end
   end

   // Drive the APB ready signal: high during WAIT state (transaction in progress), low in IDLE.
   always @(*) begin
       pread = apb_state;
   end

   // Update the predict_history register on the rising edge of history_shift_valid.
   // - If a misprediction occurs (control_reg[2] = 1), then predict_history is loaded with the concatenation
   //   of train_history (7 bits) and train_taken (control_reg[3]).
   // - Otherwise, if a valid prediction is asserted (control_reg[0] = 1), the register is shifted left and
   //   the new bit (control_reg[1]) is inserted at the LSB.
   // - If neither condition is met, the register holds its previous value.
   always @(posedge history_shift_valid or negedge presetn) begin
       if (!presetn)
           predict_history_reg <= 8'b0;
       else begin
           if (control_reg[2]) begin
               // Misprediction handling: load history with train_history (7 bits) and train_taken (1 bit)
               predict_history_reg <= {train_history_reg[6:0], control_reg[3]};
           end else if (control_reg[0]) begin
               // Normal update: shift left and insert predict_taken at LSB
               predict_history_reg <= {predict_history_reg[6:0], control_reg[1]};
           end else begin
               // No update: hold previous value
               predict_history_reg <= predict_history_reg;
           end
       end
   end

   // Continuous assignments for output signals.
   always @(*) begin
       prdata        = prdata_reg;
       pslverr       = pslverr_reg;
       history_full  = (predict_history_reg == 8'hFF);
       history_empty = (predict_history_reg == 8'h00);
       error_flag    = pslverr_reg;
       interrupt_full= history_full;
       interrupt_error = error_flag;
   end

endmodule