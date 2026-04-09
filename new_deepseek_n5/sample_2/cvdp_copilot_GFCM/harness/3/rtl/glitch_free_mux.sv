module glitch_free_mux
(
    input clk1, 
    input clk2, 
    input rst_n, 
    input sel, 
    output clkout
);

reg clkout_reg;
reg clk1_enable, clk2_enable;
reg clk1_sel, clk2_sel;
reg sel_en1, sel_en2;

// Synchronized enable signals
always @posedge clk1 or posedge rst_n) begin
    if (~rst_n) begin
        sel_en1 <= ~sel; 
    end else begin
        sel_en1 <= sel_en2 & ~clk1_enable;
    end 
end

always @posedge clk2 or posedge rst_n) begin
    if (~rst_n) begin
        sel_en2 <= sel; 
    end else begin
        sel_en2 <= sel_en1 & ~clk2_enable;
    end 
end

// Enable logic with flip-flops for clock domain crossing
always @posedge clk1 or posedge rst_n) begin
    if (~rst_n) begin
        clk1_enable <= 0 ; 
    end else begin
        clk1_enable <= ~clk1_sel;
    end 
end

always @posedge clk2 or posedge rst_n) begin
    if (~rst_n) begin
        clk2_enable <= 0 ; 
    end else begin
        clk2_enable <= ~clk2_sel;
    end 
end

// Output logic
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable);

// Synchronized sel signals
always @posedge sel or posedge rst_n) begin
    sel_en1 <= ~sel;
end

always @posedge sel or posedge rst_n) begin
    sel_en2 <= sel;
end

endmodule