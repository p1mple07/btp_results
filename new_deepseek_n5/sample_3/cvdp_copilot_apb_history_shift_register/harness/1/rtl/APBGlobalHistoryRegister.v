module APBGlobalHistoryRegister (
    input pclk, 
    input presetn, 
    input paddr, 
    input pselx, 
    input penable, 
    input pwrite, 
    input pwdata, 
    output prdata, 
    output pready, 
    output predict_history,
    output history_full, 
    output history_empty, 
    output error_flag, 
    output interrupt_full, 
    output interrupt_error
);

    // 8-bit shift register
    reg [7:0] predict_history;

    // 8-bit shift register with DFFs
    D8 D7 D6 D5 D4 D3 D2 D1 D0 (
        input pclk,
        input presetn,
        input pwrite,
        input pselx,
        input penable,
        input pwrite,
        input pselx,
        input penable
    );

    // Control logic
    reg predict_valid, predict_taken, train_mispredicted, train_taken;

    // Error handling
    reg error_flag;

    // Priority encoder
    assign predict_taken = (predict_valid && !train_mispredicted) ? (predict_taken) : (train_taken);

    // Shift logic
    always_posedge history_shift_valid begin
        if (predict_valid && !train_mispredicted) {
            // Normal shift
            predict_history = (predict_history << 1) | (predict_taken ? 1'b1 : 1'b0);
        } else if (train_mispredicted) {
            // Misprediction: load history and add new bit
            predict_history = (train_history << 7) | (train_taken ? 1'b1 : 1'b0);
        }
    end

    // Clock gating
    wire (pclk & clk_gate_en) ? pclk : 0;

    // Read operation
    always prdata = (paddr & 0x7) ? pwdata : 0;
    always posedge pclk begin
        prdata = 1;
        pready = 1;
    end

    // Write operation
    always pwrite ? prdata = pwdata : 0;

    // Asynchronous reset
    always presetn begin
        predict_history = 8'b0;
        history_full = 0;
        history_empty = 1;
        error_flag = 0;
        prdata = 0;
        pready = 0;
    end

    // Error handling
    always posedge pclk begin
        if (paddr & 0x80) error_flag = 1;
        prdata = 0;
    end

    // Priority
    assign priority = (predict_valid && !train_mispredicted) ? 1 : (train_mispredicted ? 1 : 0);

    // Outputs
    history_full = (predict_history == 8'b11111111);
    history_empty = (predict_history == 8'b00000000);
    interrupt_full = history_full;
    interrupt_error = error_flag;
endmodule