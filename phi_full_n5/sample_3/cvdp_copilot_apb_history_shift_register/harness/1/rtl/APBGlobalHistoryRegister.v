module APBGlobalHistoryRegister (
    input clk_gate_en,
    input pclk,
    input presetn,
    input [9:0] paddr,
    input selx,
    input en,
    input write,
    input [7:0] pwdata,
    output reg pready,
    output reg [7:0] prdata,
    output reg pslverr,
    output reg history_full,
    output reg history_empty,
    output reg error_flag,
    output reg interrupt_full,
    output reg interrupt_error
);

    // Control Register
    reg [7:0] control_register;
    reg [7:0] train_history;
    reg [7:0] predict_history;

    // Clock Gating
    reg clk_gate_active;

    always @(posedge pclk) begin
        if (clk_gate_en && !clk_gate_active) begin
            clk_gate_active <= 1;
        end else begin
            clk_gate_active <= 0;
        end
    end

    // Reset Behavior
    always @(posedge presetn) begin
        control_register <= 8'b0;
        train_history <= 8'b0;
        predict_history <= 8'b0;
        pready <= 1'b0;
        prdata <= 8'b0;
        pslverr <= 1'b0;
    end

    // Read/Write Operations
    always @(posedge pclk) begin
        if (clk_gate_active) begin
            case (selx)
                0: begin
                    if (en) begin
                        if (write) begin
                            control_register <= pwdata;
                        end
                    end
                end
                1: begin
                    if (en) begin
                        prdata <= control_register;
                        pready <= 1'b1;
                    end
                end
            endcase
        end
    end

    // Update Logic
    always @(posedge history_shift_valid) begin
        if (history_shift_valid && !presetn) begin
            if (predict_valid) begin
                predict_history <= predict_taken;
            end else begin
                predict_history <= train_history << 1;
                predict_history[7] <= train_taken;
            end
        end

        // Interrupt Signals
        history_full <= (predict_history == 8'hFF);
        history_empty <= (predict_history == 8'h00);
        error_flag <= (paddr >= 10'h0000000000 && paddr <= 10'hFFFFFFFFFF);
        interrupt_full <= history_full;
        interrupt_error <= error_flag;
    end

endmodule
