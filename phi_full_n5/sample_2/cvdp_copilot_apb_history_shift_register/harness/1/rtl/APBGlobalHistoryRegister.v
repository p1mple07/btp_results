module APBGlobalHistoryRegister(
    pclk,
    presetn,
    history_shift_valid,
    clk_gate_en,
    paddr,
    pselx,
    penable,
    pwrite,
    pwdata,
    pready,
    prdata,
    pslverr,
    history_full,
    history_empty,
    error_flag,
    interrupt_full,
    interrupt_error
);

    input pclk, presetn, history_shift_valid;
    input clk_gate_en;
    input [10:0] paddr;
    input pselx, penable, pwrite;
    input [7:0] pwdata;
    output reg [7:0] prdata;
    output reg pready, pslverr;
    output reg history_full, history_empty, error_flag, interrupt_full, interrupt_error;

    reg [7:0] control_register, train_history, predict_history;
    reg [7:0] shift_reg;
    reg [7:0] history_shift_reg;

    // Clock gating
    always @(posedge pclk) begin
        if (clk_gate_en) begin
            pready <= 1;
            shift_reg <= 8'b0;
        end else begin
            pready <= 0;
            shift_reg <= 8'bX; // X indicates no clock
        end
    end

    // Control Register
    always @(posedge pclk) begin
        if (presetn) begin
            control_register <= 8'b0;
            train_history <= 8'b0;
            predict_history <= 8'b0;
        end else begin
            case (pselx)
                0: control_register <= paddr;
                1: train_history <= paddr;
                default: pslverr <= 1'b1;
            endcase
        end
    end

    // Read and write operations
    always @(posedge pclk) begin
        if (penable && pwrite) begin
            case (pselx)
                0: control_register <= pwdata;
                1: train_history <= pwdata;
                default: pslverr <= 1'b1;
            endcase
        end
        prdata <= control_register;
    end

    // Interrupt and status signals
    always @(posedge pclk) begin
        if (pselx == 0 && penable) begin
            if (control_register[7:4] == 8'b0000) begin
                history_full <= (shift_reg == 8'hFF);
                interrupt_full <= history_full;
            end else begin
                history_full <= 0;
                interrupt_full <= 0;
            end
        end else if (pselx == 1 && penable) begin
            if (train_history[7] == 8'h0000) begin
                history_empty <= (shift_reg == 8'h0000);
                interrupt_empty <= history_empty;
            end else begin
                history_empty <= 0;
                interrupt_empty <= 0;
            end
        end
        error_flag <= control_register[7];
        interrupt_error <= error_flag;
    end

    // Shift register update logic
    always @(posedge history_shift_valid) begin
        if (history_shift_valid && ~pslverr) begin
            if (control_register[0]) begin
                shift_reg <<= control_register[1];
                predict_history <= shift_reg;
            end else begin
                shift_reg <= train_history << control_register[3];
                predict_history <= shift_reg;
            end
        end
    end

endmodule
