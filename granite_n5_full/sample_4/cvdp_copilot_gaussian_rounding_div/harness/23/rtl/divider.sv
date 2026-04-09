module divider #(parameter WIDTH=32) (
    input  wire                 clk,                // Clock signal
    input  wire                 rst_n,              // Negative-edge triggered active-low synchronous reset.
    input  wire [WIDTH-1:0]  dividend,          // Dividend to divide
    input  wire [WIDTH-1:0]  divisor,            // Divisor to divide
    output wire [WIDTH-1:0]  quotient,           // Quotient
    output wire [WIDTH-1:0]  remainder,          // Remainder
    output wire                 valid               // Is the result valid?
    );
//... (the rest of the original code)