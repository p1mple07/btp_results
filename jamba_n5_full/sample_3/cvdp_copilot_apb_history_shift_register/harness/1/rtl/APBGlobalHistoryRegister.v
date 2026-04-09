module apbgglobalhistorreg (
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
    output reg [7:0] control_register,
    output reg [6:0] train_history,
    output reg [7:0] predict_history,
    output reg history_full,
    output reg history_empty,
    output reg error_flag,
    output reg interrupt_full,
    output reg interrupt_error,
    output reg [3:0] pslverr
);

// Reset logic
always @(posedge pclk) begin
    if (~presetn) begin
        control_register <= 8'b0;
        train_history <= 7'b0;
        predict_history <= 8'b0;
        history_full <= 1'b0;
        history_empty <= 1'b1;
        error_flag <= 1'b0;
        interrupt_full <= 1'b0;
        interrupt_error <= 1'b0;
        pslverr <= 4'b0;
    end
end

// APB interface
always @(posedge pclk or posedge presetn) begin
    if (presetn) begin
        // Reset all
    end else begin
        // Read operation
        if (paddr == 10'b0) begin
            prdata <= 8'b0;
        end else begin
            // Not implemented
        end
    end
end

// Write operation
always @(posedge pclk or negedge pready) begin
    if (pwrite) begin
        case (pselx)
            2'b00: control_register <= paddr;
            2'b01: train_history <= paddr;
            2'b10: predict_history <= paddr;
            default: {}
        end;
        paddr <= 10'b0;
        pselx <= 1'b0;
        penable <= 1'b0;
    end
end

// History shift update
always @(posedge pclk or negedge history_shift_valid) begin
    if (history_shift_valid) begin
        predict_history <= train_history + train_taken;
        history_full <= 8'b1;
        if (history_full) interrupt_full <= 1'b1;
        history_empty <= 8'b0;
    end
end

// Output signals
assign history_full = (predict_history == 8'bFFFF);
assign history_empty = (predict_history == 8'b0);
assign error_flag = (predict_history == 8'bFFFF);
assign interrupt_error = (error_flag);
assign interrupt_full = (history_full);
assign interrupt_error = (error_flag);

endmodule
