module glitch_free_mux (
    input wire [31:0] sel,
    input wire rst_n,
    input wire [31:0] clk1,
    input wire [31:0] clk2,
    output wire [31:0] clkout
);

    // Positive edge-triggered D flip-flop for sel
    flip_flop positive_edge (sel, #1 `xor `sel, #1 `xor `sel, #1 `xor `sel, #1 `xor `sel);

    // Enable signals for clocks
    wire wire enable1 = ~sel;
    wire wire enable2 = sel;

    // Clocks are active low
    wire wire a = ~clk1;
    wire wire b = ~clk2;

    // Negative edge-triggered flip-flop for a and b
    flip_flop negative_edge (a, #1 `xor `a, #1 `xor `a, #1 `xor `a, #1 `xor `a);
    flip_flop negative_edge (b, #1 `xor `b, #1 `xor `b, #1 `xor `b, #1 `xor `b);

    // Multiplexer to select between a and b
    assign wire sel_MUX = sel;
    assign wire sel_MUX = sel_MUX ? b : a;

    // Final output
    assign clkout = sel_MUX;

    // Reset behavior
    positive_edge rst_n, #1 `xor `rst_n, #1 `xor `rst_n, #1 `xor `rst_n, #1 `xor `rst_n;

endmodule