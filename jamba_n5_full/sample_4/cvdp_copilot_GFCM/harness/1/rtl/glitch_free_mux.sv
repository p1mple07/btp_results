module glitching_free_mux (
    input clk1, clk2, sel,
    output reg clkout
);

    // Internal state: which clock is currently selected
    reg clk_source;

    always @(posedge clk1 or posedge clk2 or negedge rst) begin
        if (rst)
            clk_source <= 1'b0;
        else if (sel == 1'b0) begin
            if (clk1) begin
                clk_source <= 1'b0; // keep it as clk1
            end else begin
                clk_source <= 1'b1; // switch to clk2
            end
        end else begin
            if (clk2) begin
                clk_source <= 1'b1;
            end else begin
                clk_source <= 1'b0;
            end
        end
    end

    assign clkout = clk_source;

endmodule
