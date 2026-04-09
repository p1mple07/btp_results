module APBGlobalHistoryRegister (
    input  wire         pclk,         // APB clock input
    input  wire         presetn,      // Asynchronous reset (active low)
    input  wire         pselx,        // APB select signal
    input  wire         penable,      // APB enable signal
    input  wire         pwrite,       // Write enable (1 = write, 0 = read)
    input  wire         clk_gate_en,  // Clock gating enable (asserted to gate pclk)
    input  wire         history_shift_valid, // Signal for updating history register
    input  wire [9:0]   paddr,        // 10-bit APB address bus
    input  wire [7:0]   pwdata,       // 8-bit write data bus
    output reg  [7:0]   prdata,       // 8-bit read data bus
    output reg          pread,        // APB ready signal
    output reg          pslverr,      // APB error signal
    output wire         history_full, // Asserted if predict_history == 8'hFF
    output wire         history_empty,// Asserted if predict_history == 8'h00
    output wire         interrupt_full,// Interrupt when history is full
    output wire         interrupt_error// Interrupt when an error is detected
);

    // Internal registers for APB accessible registers
    reg [7:0] control_register;  // Address 0x0
    reg [7:0] train_history;     // Address 0x1 (only bits[6:0] are used)
    reg [7:0] predict_history;   // Address 0x2 (read-only via APB)
    reg       error_flag;        // Flag for error detection (invalid address)
    
    // State register for simple two-cycle APB transaction
    reg [1:0] state;
    localparam IDLE = 2'b00,
               WRITE = 2'b01,
               READ  = 2'b10;
               
    // Gated clock: gating pclk with clk_gate_en for power efficiency.
    // Note: clk_gate_en is assumed to toggle only on the negative edge of pclk.
    wire gated_pclk = pclk & clk_gate_en;
    
    // APB ready signal is always high (completes transactions in two cycles)
    assign pread = 1'b1;
    
    // APB state machine operating in the gated clock domain.
    always @(posedge gated_pclk or negedge presetn) begin
        if (!presetn) begin
            state            <= IDLE;
            control_register <= 8'b0;
            train_history    <= 8'b0;
            prdata           <= 8'b0;
            pslverr          <= 1'b0;
            error_flag       <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (pselx && penable) begin
                        if (pwrite)
                            state <= WRITE;
                        else
                            state <= READ;
                    end
                end
                WRITE: begin
                    // Check for valid write address.
                    // Valid addresses: 0x0 (control_register), 0x1 (train_history)
                    // Address 0x2 (predict_history) is read-only.
                    if ((paddr[9:2] == 8'h00) || 
                        (paddr[9:2] == 8'h01) || 
                        ((paddr[9:2] == 8'h02) && !pwrite)) begin
                        if (paddr[9:2] == 8'h00) begin
                            control_register <= pwdata;
                        end else if (paddr[9:2] == 8'h01) begin
                            train_history <= pwdata;
                        end else if (paddr[9:2] == 8'h02) begin
                            // predict_history is read-only; ignore write.
                        end
                        pslverr    <= 1'b0;
                        error_flag <= 1'b0;
                    end else begin
                        pslverr    <= 1'b1;
                        error_flag <= 1'b1;
                    end
                    state <= IDLE;
                end
                READ: begin
                    // Determine read data based on address.
                    if (paddr[9:2] == 8'h00) begin
                        prdata <= control_register;
                    end else if (paddr[9:2] == 8'h01) begin
                        prdata <= train_history;
                    end else if (paddr[9:2] == 8'h02) begin
                        prdata <= predict_history;
                    end else begin
                        prdata <= 8'b0;
                        pslverr    <= 1'b1;
                        error_flag <= 1'b1;
                    end
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    // History register update logic on the rising edge of history_shift_valid.
    // This always block is independent of the APB clock domain.
    always @(posedge history_shift_valid or negedge presetn) begin
        if (!presetn)
            predict_history <= 8'b0;
        else begin
            // Misprediction takes highest priority.
            if (control_register[2] == 1'b1) begin
                // Misprediction update: load {train_history[6:0], train_taken}
                predict_history <= {train_history[6:0], control_register[3]};
            end else if (control_register[0] == 1'b1) begin
                // Normal update: shift in predict_taken as LSB.
                predict_history <= {predict_history[7:1], control_register[1]};
            end else begin
                // No update; retain previous state.
                predict_history <= predict_history;
            end
        end
    end
    
    // Status and Interrupt Signals
    assign history_full   = (predict_history == 8'hFF);
    assign history_empty  = (predict_history == 8'h00);
    assign interrupt_full = history_full;
    assign interrupt_error= error_flag;
    
endmodule