module apb_controller(
    input wire clk,
    input wire reset_n,
    input wire select_a_i, select_b_i, select_c_i,
    input wire [31:0] addr_a_i, data_a_i,
    input wire [31:0] addr_b_i, data_b_i,
    input wire [31:0] addr_c_i, data_c_i,
    input wire apb_pready_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output wire apb_pwrite_o,
    output wire apb_paddr_o [31:0],
    output wire apb_pwdata_o [31:0]
);

// Reset logic
always @(posedge clk or posedge reset_n) begin
    if (reset_n) begin
        apb_psel_o <= 1'b0;
        apb_penable_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
    end else begin
        // Check for any event
        if (select_a_i || select_b_i || select_c_i) begin
            // Determine highest priority
            if (select_a_i) begin
                apb_psel_o <= 1'b1;
            end else if (select_b_i) begin
                apb_psel_o <= 1'b1;
            end else if (select_c_i) begin
                apb_psel_o <= 1'b1;
            end
        end else begin
            apb_psel_o <= 1'b0;
        end
    end
end

// Setup phase
always @(apb_psel_o) begin
    if (apb_psel_o && apb_penable_o == 1'b0) begin
        // Enter setup
        apb_paddr_o <= addr_a_i;
        apb_pwdata_o <= data_a_i;
    end
end

// Access phase
always @(apb_pready_i) begin
    if (apb_pready_i) begin
        apb_pwrite_o <= 1'b1;
        apb_penable_o <= 1'b1;
    end else begin
        apb_pwrite_o <= 1'b0;
        apb_penable_o <= 1'b0;
    end
end

// Timeout detection
always @(posedge clk) begin
    if (apb_pready_i == 1'b0) begin
        apb_penable_o <= 1'b0;
        // Start timeout counter
        if (!apb_pready_i) begin
            apb_timeout_cnt <= 0;
        end
        apb_timeout_cnt <= apb_timeout_cnt + 1;
    end
end

always @(apb_timeout_cnt) begin
    if (apb_timeout_cnt >= 15) begin
        apb_psel_o <= 1'b0;
        apb_penable_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
        apb_timeout_cnt <= 0;
    end
end

endmodule
