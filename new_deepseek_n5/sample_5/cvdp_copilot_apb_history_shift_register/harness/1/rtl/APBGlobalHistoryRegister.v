module APBGlobalHistoryRegister (
    input pclk,
    input presetn,
    input paddr,
    input pselx,
    input penable,
    input pwrite,
    input pwdata,
    output prdata,
    output ready,
    output prdata,
    output error_flag,
    output history_full,
    output history_empty,
    output history_full,
    output error_flag,
    output interrupt_full,
    output interrupt_error
    );

    // 8-bit shift register
    reg [7:0] predict_history;

    // 7-bit train history
    reg [6:0] train_history;

    // 9-bit control register (3+6)
    reg [8:0] control_register;

    // Clock gating control
    reg clock_gating = 1;

    // State variables
    reg [1:0] state = 0;

    // Error flag
    reg error_flag = 0;

    // Module ports
    output prdata;
    output ready;
    output error_flag;
    output history_full;
    output history_empty;
    output interrupt_full;
    output interrupt_error;

    // Edge-triggered assignments
    always edge (pclk) begin
        if (presetn) begin
            ready = 1;
            prdata = 0;
            control_register = 0;
            train_history = 0;
            predict_history = 0;
            error_flag = 0;
            history_full = 0;
            history_empty = 1;
            state = 0;
        end else begin
            ready = 1;
        end
    end

    // Shift register logic
    always edge (history_shift_valid) begin
        case (state)
            0: 
                // Initialize
                ready = 1;
                prdata = 0;
                control_register = 0;
                train_history = 0;
                predict_history = 0;
                error_flag = 0;
                history_full = 0;
                history_empty = 1;
                state = 1;
                break;
            1: 
                // Normal update
                if (predict_valid && !train_mispredicted) begin
                    prdata = (predict_taken << 7) | (predict_history[7:0] >> 1);
                    predict_history = predict_history[7:0] >> 1;
                    prdata = prdata[7:0];
                end else if (train_mispredicted) begin
                    // Misprediction update
                    prdata = (train_history[6:0] << 1) | train_taken;
                    predict_history = predict_history[7:0] >> 1;
                    predict_history[0] = prdata[7];
                    prdata = prdata[7:0];
                end else begin
                    // No change
                    prdata = predict_history[7:0];
                end
                state = 2;
                break;
            2: 
                // Check for full/empty
                history_full = 1;
                history_empty = 1;
                state = 3;
                break;
            3: 
                // Update status signals
                if (predict_history[7]) history_full = 0;
                if (predict_history[0]) history_empty = 0;
                state = 4;
                break;
            default:
                state = 4;
                break;
        endcase
    end

    // Control register logic
    always edge (paddr) begin
        if (pselx && penable && pwrite) begin
            control_register[2:0] = (predict_valid && !train_mispredicted) ? (predict_taken << 2) | (train_mispredicted ? (train_taken << 2) | (predict_taken) : 0) : 0;
        end
    end

    // History update logic
    always edge (paddr) begin
        if (pselx && penable && pwrite) begin
            if (predict_valid && !train_mispredicted) begin
                train_history = (predict_taken << 7) | (predict_history[7:0] >> 1);
            else if (train_mispredicted) begin
                train_history = (train_history[6:0] << 1) | train_taken;
            end
        end
    end

    // Error handling
    always edge (paddr) begin
        if (paddr[7:0] > 7) begin
            error_flag = 1;
            ready = 0;
        end
    end