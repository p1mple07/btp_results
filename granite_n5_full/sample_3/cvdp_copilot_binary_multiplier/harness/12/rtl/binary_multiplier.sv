module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic clk,         // Clock signal for synchronization
    input  logic rst_n,       // Active-low asynchronous reset
    input  logic valid_in,   // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,          // Input A
    input  logic [WIDTH-1:0] B,          // Input B
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic valid_out   // Output valid
);

// Sequential approach implementation
//...

// Rest of the module implementation
//...

endmodule