module APBGlobalHistoryRegister (
    input pclk,
    input presetn,
    input paddr,
    input pselx,
    input penable,
    input pwrite,
    input pwdata,
    input pready,
    input prdata,
    input pslverr,
    input history_shift_valid,
    input clock_gate_en,
    output prdata,
    output history_full,
    output history_empty,
    output error_flag,
    output interrupt_full,
    output interrupt_error
);

    // Registers
    reg8 predict_history;
    reg9 control_register = 8'b000000000;
    reg7 train_history = 7'b0000000;
    reg8 train_history_out = 8'b00000000;

    // Clock gating
    clock_gating pclk_gated (pclk, clock_gate_en);

    // Initialize on presetn
    always_negedge presetn begin
        prdata = 8'b0;
        pslverr = 0;
        history_full = 0;
        history_empty = 1;
        error_flag = 0;
        control_register = 8'b000000000;
        train_history = 7'b0000000;
    end

    // Update logic
    always clock edge sensitivity begin
        if (history_shift_valid) begin
            if (predict_valid & !train_mispredicted) begin
                // Normal update
                predict_history = (predict_history << 1) | predict_taken;
            else if (train_mispredicted) begin
                // Misprediction update
                train_history_out = (train_history << 1) | train_taken;
                predict_history = train_history_out;
            end
            // Priority: Mis prediction takes precedence
            if (train_mispredicted) predict_history = train_history_out;
        end
    end

    // Output signals
    prdata = predict_history;
    history_full = (predict_history == 8'hFF);
    history_empty = (predict_history == 8'h00);
    error_flag = pslverr;
    interrupt_full = history_full;
    interrupt_error = error_flag;

endmodule