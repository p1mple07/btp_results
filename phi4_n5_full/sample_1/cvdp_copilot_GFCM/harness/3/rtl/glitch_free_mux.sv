module glitch_free_mux
(
    input         clk1,    // asynchronous clock 1
    input         clk2,    // asynchronous clock 2
    input         rst_n,   // asynchronous reset (active low)
    input         sel,     // selection signal (synchronous to clk1)
    output        clkout   // clock output
);

//-----------------------------------------------------------------
// Internal signals for clock enable generation and crossing
//-----------------------------------------------------------------
// For clk1_enable: launched in clk1 domain, captured in clk2 domain
reg clk1_enable_l;
reg clk1_enable_c;

// For clk2_enable: launched in clk2 domain, captured in clk1 domain
reg clk2_enable_l;
reg clk2_enable_c;

// Synchronizer for sel in clk2 domain (since sel is synchronous to clk1)
reg sel_sync [1:0];

//-----------------------------------------------------------------
// Synchronize sel to clk2 domain (two-flop synchronizer)
//-----------------------------------------------------------------
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        sel_sync[0] <= 1'b0;
    else
        sel_sync[0] <= sel;
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        sel_sync[1] <= 1'b0;
    else
        sel_sync[1] <= sel_sync[0];
end

//-----------------------------------------------------------------
// Generate clk1_enable in clk1 domain (launched value)
// When sel = 0, clk1_enable_l is enabled if clk2_enable_c is low.
//-----------------------------------------------------------------
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n)
        clk1_enable_l <= 1'b0;
    else
        clk1_enable_l <= ~clk2_enable_c & ~sel;  // sel is safe in clk1 domain
end

//-----------------------------------------------------------------
// Generate clk2_enable in clk2 domain (launched value)
// Use synchronized sel (sel_sync[1]) because sel is asynchronous to clk2.
//-----------------------------------------------------------------
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        clk2_enable_l <= 1'b0;
    else
        clk2_enable_l <= ~clk1_enable_c & sel_sync[1];
end

//-----------------------------------------------------------------
// Capture clk1_enable from clk1 domain to clk2 domain
//-----------------------------------------------------------------
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        clk1_enable_c <= 1'b0;
    else
        clk1_enable_c <= clk1_enable_l;
end

//-----------------------------------------------------------------
// Capture clk2_enable from clk2 domain to clk1 domain
//-----------------------------------------------------------------
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n)
        clk2_enable_c <= 1'b0;
    else
        clk2_enable_c <= clk2_enable_l;
end

//-----------------------------------------------------------------
// Output clock generation
// Use the launched enable signals (which are synchronous to their
// respective clocks) to select the output clock.
// When sel = 0: clk1 is enabled (and clk2 is disabled).
// When sel = 1: clk2 is enabled (and clk1 is disabled).
// The two-cycle delay in the enable generation ensures glitch-free switching.
//-----------------------------------------------------------------
assign clkout = (clk1 & clk1_enable_l) | (clk2 & clk2_enable_l);

endmodule