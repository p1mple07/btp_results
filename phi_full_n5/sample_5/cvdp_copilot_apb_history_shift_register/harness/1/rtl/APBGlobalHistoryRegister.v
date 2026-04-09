module APBGlobalHistoryRegister(
    input clk_gate_en,
    input pclk,
    input presetn,
    input [10:0] paddr,
    input pselx,
    input en,
    input write,
    input write_en,
    input [8:0] pwdata,
    output reg [7:0] prdata,
    output reg pready,
    output reg pslverr,
    output reg history_full,
    output reg history_empty,
    output reg error_flag,
    output reg interrupt_full,
    output reg interrupt_error
);

    // Internal signals
    reg [7:0] control_register;
    reg [7:0] train_history;
    reg [7:0] predict_history;
    reg history_shift_valid;

    // Register description
    always @(posedge pclk or posedge presetn) begin
        if (presetn) begin
            control_register <= 8'b0;
            train_history <= 8'b0;
            predict_history <= 8'b0;
            pready <= 0;
            pslverr <= 0;
            history_full <= 0;
            history_empty <= 1;
            interrupt_full <= 0;
            interrupt_error <= 0;
        end else begin
            case (paddr)
                0x0: control_register <= pwdata;
                0x1: train_history <= pwdata;
                0x2: predict_history <= pwdata;
                default: pslverr <= 1;
            endcase
        end
    end

    // Interrupt signals
    always @(paddr) begin
        if (paddr == 0x2) begin
            interrupt_full <= history_full;
            interrupt_error <= error_flag;
        end
    end

    // Clock gating
    assign clk_gate_en = ~clk_gate_en;

    // Control register logic
    always @(posedge pclk or posedge history_shift_valid) begin
        if (pclk && !clk_gate_en) begin
            if (write && write_en) begin
                control_register <= pwdata;
                pready <= 1;
            end
        end

        if (history_shift_valid) begin
            if (predict_valid) begin
                predict_history <= {predict_history[6:0], predict_taken};
            end else if (train_mispredicted) begin
                predict_history <= {train_history[6:0], train_taken};
            end

            // Update interrupt flags
            history_full <= (predict_history == 8'hFF);
            history_empty <= (predict_history == 8'h00);
            error_flag <= (paddr == 0x2 && pselx);
        end
    end

    // Reset logic
    always @(posedge presetn) begin
        if (!presetn) begin
            control_register <= 8'b0;
            train_history <= 8'b0;
            predict_history <= 8'b0;
            pready <= 0;
            pslverr <= 0;
            history_full <= 0;
            history_empty <= 1;
            interrupt_full <= 0;
            interrupt_error <= 0;
        end
    end

    // Interrupt logic
    always @(paddr) begin
        if (paddr == 0x2) begin
            error_flag <= (pselx);
        end
    end

endmodule
