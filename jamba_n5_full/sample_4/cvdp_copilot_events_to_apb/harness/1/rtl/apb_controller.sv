module apb_controller (
    input  clk,
    input  reset_n,
    input  select_a_i, select_b_i, select_c_i,
    input  [31:0] addr_a_i, data_a_i,
    input  [31:0] addr_b_i, data_b_i,
    input  [31:0] addr_c_i, data_c_i,
    input  apb_pready_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output reg apb_paddr_o [31:0],
    output reg apb_pwdata_o [31:0]
);

reg current_state;
reg timeout;

always @(posedge clk) begin
    if (!reset_n) begin
        apb_psel_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
        apb_penable_o <= 1'b0;
        current_state = IDLE;
        timeout <= 0;
    end else begin
        // Check for asserted events
        if (select_a_i & apb_pready_i) begin
            current_state = SETUP;
            apb_psel_o <= 1'b1;
            apb_pwrite_o <= 1'b1;
            apb_paddr_o <= addr_a_i[31:0];
            apb_pwdata_o <= data_a_i[31:0];
        end else if (select_b_i & apb_pready_i) begin
            current_state = SETUP;
            apb_psel_o <= 1'b1;
            apb_pwrite_o <= 1'b1;
            apb_paddr_o <= addr_b_i[31:0];
            apb_pwdata_o <= data_b_i[31:0];
        end else if (select_c_i & apb_pready_i) begin
            current_state = SETUP;
            apb_psel_o <= 1'b1;
            apb_pwrite_o <= 1'b1;
            apb_paddr_o <= addr_c_i[31:0];
            apb_pwdata_o <= data_c_i[31:0];
        end else begin
            current_state = IDLE;
        end
    end
end

always @(posedge clk) begin
    if (current_state == IDLE) begin
        if (apb_psel_o && apb_pwrite_o && apb_paddr_o) begin
            apb_penable_o <= 1'b1;
            apb_pready_i <= 1;
        end else begin
            apb_penable_o <= 1'b0;
        end
    end
end

always @(*) begin
    if (apb_penable_o) begin
        if (apb_pready_i) begin
            apb_pwrite_o <= 1'b1;
            apb_pwdata_o <= apb_data_o_input;
        end else begin
            apb_pwrite_o <= 1'b0;
        end
    end
end

always @(posedge clk) begin
    if (current_state == SETUP) begin
        timeout <= 0;
        apb_psel_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
    end
end

always @(posedge clk) begin
    if (current_state == ACCESS) begin
        if (!apb_pready_i) begin
            timeout <= timeout + 1;
            if (timeout >= 15) begin
                apb_pwrite_o <= 1'b0;
                apb_psel_o <= 1'b0;
                apb_pwrite_o <= 1'b0;
                apb_paddr_o <= 0;
                apb_pwdata_o <= 0;
                current_state = IDLE;
            end
        end else begin
            apb_pready_i <= 1;
        end
    end
end

always @(posedge clk) begin
    if (current_state == ACCESS) begin
        if (apb_pready_i) begin
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
        end
    end
end

endmodule
