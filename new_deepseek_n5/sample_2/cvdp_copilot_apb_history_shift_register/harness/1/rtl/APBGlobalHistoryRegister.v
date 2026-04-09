module APBGlobalHistoryRegister (
    input clock pclk,
    input low presetn,
    input paddr,
    input pselx,
    input penable,
    input pwrite,
    input pwdata,
    output prdata,
    output ready,
    output pr ready,
    output prdata,
    output error_flag,
    output history_full,
    output history_empty,
    output interrupt_full,
    output interrupt_error
);

    reg8 predict_history;
    reg8 control_register;
    reg8 train_history;

    always clock pclk, presetn #+ (history_shift_valid: '1');
        if (presetn) begin
            ready = 1;
            prdata = 8'b0;
            error_flag = 0;
            history_full = 0;
            history_empty = 1;
            // Initialize registers
            control_register = 8'b0;
            train_history = 7'b0;
        end else if (pwrite & !penable) begin
            // Error handling
            if (paddr < 0 || paddr >= 3) begin
                error_flag = 1;
                prdata = 8'b0;
            end else if (pwrite) begin
                prdata = pwdata;
            end else begin
                prdata = 8'b0;
            end
        end else if (history_shift_valid) begin
            // Perform shift operation
            if (predict_valid & !train_mispredicted) begin
                // Normal update
                predict_history = (predict_history << 1) | predict_taken;
            else if (train_mispredicted) begin
                // Misprediction update
                predict_history = (train_history << 7) | train_taken;
            end else begin
                // Default case
                predict_history = 8'b0;
            end
        end
    end

    // State management
    always clock pclk, presetn begin
        if (presetn) begin
            ready = 1;
            prdata = 8'b0;
            error_flag = 0;
            history_full = 0;
            history_empty = 1;
            control_register = 8'b0;
            train_history = 7'b0;
        end else if (pwrite & !penable) begin
            if (paddr < 0 || paddr >= 3) begin
                error_flag = 1;
                prdata = 8'b0;
            end else if (pwrite) begin
                prdata = pwdata;
            end else begin
                prdata = 8'b0;
            end
        end else if (history_shift_valid) begin
            if (predict_valid & !train_mispredicted) begin
                predict_history = (predict_history << 1) | predict_taken;
            else if (train_mispredicted) begin
                predict_history = (train_history << 7) | train_taken;
            end else begin
                predict_history = 8'b0;
            end
        end
    end

    // Outputs
    history_full = (predict_history == 8'b11111111);
    history_empty = (predict_history == 8'b00000000);
    interrupt_full = history_full;
    interrupt_error = error_flag;
endmodule