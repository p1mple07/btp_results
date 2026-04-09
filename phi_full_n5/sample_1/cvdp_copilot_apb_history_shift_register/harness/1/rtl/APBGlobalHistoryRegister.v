module APBGlobalHistoryRegister(
    pclk, presetn, history_shift_valid, clk_gate_en,
    paddr, pselx, penable, pwrite, pwdata, pready, prdata,
    pslverr, history_full, history_empty, error_flag, interrupt_full, interrupt_error
);

    input pclk, presetn, history_shift_valid, clk_gate_en;
    input [9:0] paddr, pselx, penable, pwrite, pwdata;
    output reg pready, prdata, pslverr;
    output reg history_full, history_empty, error_flag, interrupt_full, interrupt_error;

    // Internal signals
    reg [7:0] control_register, train_history, predict_history;
    reg [7:0] shift_reg;
    logic [7:0] temp_shift;

    // Interrupt and error handling
    always @(posedge pclk) begin
        if (clk_gate_en == 1'b0 && ~presetn) begin
            pready <= 1'b0;
            pslverr <= 1'b0;
            control_register <= 8'b0;
            train_history <= 8'b0;
            predict_history <= 8'b0;
        end else begin
            pready <= 1'b1;
        end
    end

    // Control register logic
    always @(posedge penable) begin
        case (pselx)
            1'b0: begin
                if (presetn) begin
                    control_register <= 8'b0;
                end else begin
                    control_register <= 8'b0;
                    if (history_shift_valid) begin
                        case (control_register[2])
                            1'b0: begin
                                predict_history <= predict_history << 1;
                                predict_history <= predict_history | pwdata[0];
                            end
                            1'b1: begin
                                train_history <= train_history << 1;
                                train_history <= train_history | pwdata[0];
                                temp_shift = train_history << 1;
                                temp_shift = temp_shift | pwdata[1];
                                shift_reg <= temp_shift;
                                if (shift_reg == 8'hFF) begin
                                    history_full <= 1'b1;
                                    error_flag <= 1'b0;
                                end else begin
                                    history_empty <= 1'b0;
                                    error_flag <= 1'b0;
                                end
                            end
                        end
                    end
                end
            end
            1'b1: begin
                if (presetn) begin
                    control_register <= 8'b0;
                end else begin
                    control_register <= 8'b0;
                    if (history_shift_valid) begin
                        case (control_register[2])
                            1'b0: begin
                                predict_history <= predict_history << 1;
                                predict_history <= predict_history | pwdata[0];
                            end
                            1'b1: begin
                                train_history <= train_history << 1;
                                train_history <= train_history | pwdata[0];
                                temp_shift = train_history << 1;
                                temp_shift = temp_shift | pwdata[1];
                                shift_reg <= temp_shift;
                                if (shift_reg == 8'hFF) begin
                                    history_full <= 1'b1;
                                    error_flag <= 1'b0;
                                end else begin
                                    history_empty <= 1'b0;
                                    error_flag <= 1'b0;
                                end
                            end
                        end
                    end
                end
            end
        endcase
    end

    // Read and write interface logic
    always @(*) begin
        case (pselx)
            1'b0: begin
                prdata <= control_register;
                pready <= 1'b1;
            end
            1'b1: begin
                prdata <= predict_history;
                pready <= 1'b1;
            end
        endcase
    end

    // Error signal
    always @(paddr) begin
        if (paddr != 8'h0) begin
            pslverr <= 1'b1;
        end else begin
            pslverr <= 1'b0;
        end
    end

    // Interrupt logic
    always @(history_full or interrupt_error) begin
        if (history_full) begin
            interrupt_full <= 1'b1;
        end else begin
            interrupt_full <= 1'b0;
        end
        if (error_flag) begin
            interrupt_error <= 1'b1;
        end else begin
            interrupt_error <= 1'b0;
        end
    end

endmodule
