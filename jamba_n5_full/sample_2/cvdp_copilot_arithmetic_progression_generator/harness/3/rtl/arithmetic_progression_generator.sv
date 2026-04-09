module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);

    // Calculate WIDTH_OUT_VAL to avoid overflow
    localparam WIDTH_OUT_VAL = ($sizeof(unsigned));

    // ... rest of the code

    assign out_val = current_val;

endmodule
