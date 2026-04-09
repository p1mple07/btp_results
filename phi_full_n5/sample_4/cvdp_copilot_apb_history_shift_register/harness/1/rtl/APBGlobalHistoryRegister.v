module APBGlobalHistoryRegister(
    pclk,
    presetn,
    paddr,
    pselx,
    penable,
    pwrite,
    pwdata,
    pready,
    prdata,
    pslverr,
    history_shift_valid,
    clk_gate_en
);

    input pclk, presetn, history_shift_valid, clk_gate_en;
    input [9:0] paddr, pselx, penable, pwrite;
    input [7:0] pwdata;
    output reg pready, prdata, pslverr;

    reg [7:0] control_register[0:3], train_history[0:6];
    reg [7:0] predict_history;
    reg history_full, history_empty, error_flag;
    output reg interrupt_full, interrupt_error;

    // Reset logic
    always @(posedge clk_gate_en or negedge presetn) begin
        if (!presetn) begin
            pready <= 0;
            prdata <= 0;
            pslverr <= 0;
            control_register <= {8'h0, 8'h0, 8'h0, 8'h0};
            train_history <= {8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0};
            predict_history <= 8'h0;
            history_full <= 0;
            history_empty <= 1;
            error_flag <= 0;
            interrupt_full <= 0;
            interrupt_error <= 0;
        end
    end

    // Clock gating logic
    always @(posedge clk_gate_en) begin
        if (clk_gate_en) begin
            pready <= 0;
            prdata <= 0;
            pslverr <= 0;
        end
    end

    // Control register logic
    always @(posedge clk_gate_en) begin
        case (pselx)
            0: begin
                control_register <= {predict_valid, predict_taken, train_mispredicted, train_taken, 8'h0, 8'h0, 8'h0, 8'h0};
            end
            1: begin
                control_register <= {8'h0, 8'h0, 8'h0, 8'h0, predict_valid, predict_taken, train_mispredicted, train_taken};
            end
        endcase
    end

    // Train history logic
    always @(posedge clk_gate_en) begin
        if (pselx == 1) begin
            train_history <= pwdata;
        end
    end

    // Prediction history update logic
    always @(posedge clk_gate_en) begin
        if (history_shift_valid) begin
            case ({pselx, train_mispredicted})
                1'b1 | 1'b1: begin
                    predict_history <= train_history << 1;
                    if (predict_taken)
                        predict_history[0] <= predict_taken;
                    if (train_mispredicted)
                        history_full <= 1;
                    else
                        history_empty <= 1;
                end
                1'b1: begin
                    predict_history <= train_history << 7 | train_taken;
                    history_full <= 1;
                    history_empty <= 0;
                end
                default: begin
                    pslverr <= 1;
                    error_flag <= 1;
                    interrupt_error <= 1;
                end
            endcase
        end
    end

    // Interrupt logic
    always @(posedge clk_gate_en) begin
        if (history_full) begin
            interrupt_full <= 1;
        end
        if (error_flag) begin
            interrupt_error <= 1;
        end
    end

endmodule
