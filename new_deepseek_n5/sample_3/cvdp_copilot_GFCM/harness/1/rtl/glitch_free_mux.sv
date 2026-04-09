module glitch_free_mux (
    input wire [WIDTH-1:0] sel,
    input wire rst_n,
    input wire [WIDTH-1:0] clk1,
    input wire [WIDTH-1:0] clk2,
    output wire [WIDTH-1:0] clkout,
    output wire ttransition
);

    // Transition enable is active high
    wire ttransition = ~rst_n;

    // D flip-flop with hold
    DFlipFlop flip_flop (
        input wire [WIDTH-1:0] D,
        input wire Clk,
        output wire Q,
        output wire Q_bar
    );

    // Clock enable signals
    wire [WIDTH-1:0] clk1_en = ~ttransition & ~clk2;
    wire [WIDTH-1:0] clk2_en = ~ttransition & ~clk1;

    // Data input for flip-flop
    wire [WIDTH-1:0] D = sel ? (~clk2) : (~clk1);

    // Flip-flop
    flip_flop (
        D,
        ttransition,
        clkout,
        ~clkout
    );

endmodule