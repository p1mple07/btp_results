module.
interface arithmetic_progression_generator_if (input clk, resetn, enable);
    logic [DATA_WIDTH-1:0] start_val;   // Start value of the sequence
    logic [DATA_WIDTH-1:0] step_size;   // Step size of the sequence
    logic [WIDTH_OUT_VAL-1:0] out_val; // Current value of the sequence
    logic done;                        // High when sequence generation is complete
endinterface

// Implement the arithmetic_progression_generator module using the defined interface.
module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
) (
    arithmetic_progression_generator_if.master port
);
    //... (code continues from the previous snippet)
endmodule