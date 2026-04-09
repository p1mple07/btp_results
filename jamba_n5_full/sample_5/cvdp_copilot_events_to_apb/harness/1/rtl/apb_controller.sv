module apb_controller (
    input clk,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input addr_a_i,
    input data_a_i,
    input addr_b_i,
    input data_b_i,
    input addr_c_i,
    input data_c_i,
    input apb_pready_i
);

reg [31:0] apb_paddr;
reg [31:0] apb_pwdata;
reg apb_penable;
reg apb_pwrite;
reg apb_paddr_o;
reg apb_pwdata_o;
reg apb_penable_o;
reg apb_pwrite_o;
reg timeout_cnt;

initial begin
    reset_n ? ($display("Reset"), $stop);
end

always @(posedge clk) begin
    if (reset_n) begin
        apb_paddr <= 0;
        apb_pwdata <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
        apb_penable_o <= 0;
        timeout_cnt <= 0;
    end else begin
        if (select_a_i) begin
            apb_psel <= 1'b1;
            apb_paddr <= addr_a_i;
            apb_pwdata <= data_a_i;
        end else if (select_b_i) begin
            apb_psel <= 1'b1;
            apb_paddr <= addr_b_i;
            apb_pwdata <= data_b_i;
        end else if (select_c_i) begin
            apb_psel <= 1'b1;
            apb_paddr <= addr_c_i;
            apb_pwdata <= data_c_i;
        end else if (apb_psel == 1'b0) begin
            apb_penable <= 0;
        end else begin
            apb_penable <= 0;
        end
    end
end

always @(posedge clk or reset_n) begin
    if (reset_n) begin
        apb_psel <= 1'b0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        timeout_cnt <= 0;
    end else begin
        if (apb_pready_i) begin
            apb_pwrite <= 1'b1;
        end else begin
            apb_pwrite <= 1'b0;
        end
    end
end

always @(posedge clk) begin
    if (reset_n) begin
        apb_paddr <= 0;
        apb_pwdata <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
        apb_penable_o <= 0;
        timeout_cnt <= 0;
    end else begin
        if (apb_pready_i) begin
            apb_paddr <= 0;
            apb_pwdata <= 0;
            apb_penable <= 0;
            apb_pwrite <= 0;
            apb_paddr_o <= 0;
            apb_pwdata_o <= 0;
            apb_penable_o <= 0;
            timeout_cnt <= 0;
        end
    end
end

endmodule
