module APBGlobalHistoryRegister (
    input pclk,
    input presetn,
    input paddr,
    input pselx,
    input penable,
    input pwrite,
    input pwdata,
    output prdata,
    output prready,
    output prwrite,
    output prpselx,
    output prps,
    output prerr,
    output history_full,
    output history_empty,
    output error_flag,
    output interrupt_full,
    output interrupt_error
);

    // 8-bit shift register
    reg predict_history = 8'b0;

    // Status and interrupt signals
    reg prready = 0;
    reg prwrite = 0;
    reg prpselx = 0;
    reg prps = 0;
    reg prerr = 0;
    reg history_full = 0;
    reg history_empty = 0;
    reg error_flag = 0;
    reg interrupt_full = 0;
    reg interrupt_error = 0;

    // Negative edge sensitivity for presetn
    always_n @ (presetn) begin
        prready = 0;
        prwrite = 0;
        prpselx = 0;
        prps = 0;
        prerr = 0;
        history_full = 0;
        history_empty = 1;
        error_flag = 0;
        // Reset all state
        predict_history = 8'b0;
    end

    // Positive edge sensitivity for history_shift_valid
    always @ (history_shift_valid) begin
        // Negative edge sensitivity for clock gating
        if (clk_gate_en) begin
            // Update logic
            if (predict_valid & !train_mispredicted) begin
                // Normal update: shift in predict_taken
                predict_history = (predict_history << 1) | predict_taken;
                history_full = (predict_history == 8'b11111111);
                history_empty = (predict_history == 8'b00000000);
            elsif (train_mispredicted) begin
                // Misprediction: restore history and load new bit
                predict_history = (train_history << 7) | train_taken;
                history_full = (predict_history == 8'b11111111);
                history_empty = (predict_history == 8'b00000000);
            end
            // Priority: misprediction overrides prediction
        end else begin
            // No clock gating: update immediately
            if (predict_valid & !train_mispredicted) begin
                predict_history = (predict_history << 1) | predict_taken;
                history_full = (predict_history == 8'b11111111);
                history_empty = (predict_history == 8'b00000000);
            elsif (train_mispredicted) begin
                predict_history = (train_history << 7) | train_taken;
                history_full = (predict_history == 8'b11111111);
                history_empty = (predict_history == 8'b00000000);
            end
        end

        // Update status signals
        error_flag = pslverr;
        interrupt_full = history_full;
        interrupt_error = error_flag;
    end

    // Read operations
    always @ (paddr) begin
        prdata = (predict_history)[paddr+1];
    end

    // Write operations
    always @ (pwrite) begin
        prwrite = 1;
        prpselx = 0;
        prps = 0;
        prerr = 0;
        prdata = pwdata;
    end

    // Wait states are not supported
    // pready is always high
    prready = 1;
endmodule