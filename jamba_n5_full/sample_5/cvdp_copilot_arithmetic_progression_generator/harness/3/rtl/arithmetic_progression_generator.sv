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

    // Calculate the required output width to avoid overflow
    parameter WIDTH_OUT_VAL = 32;  // 32 bits can hold the maximum value safely

    // Registers
    reg [WIDTH_OUT_VAL-1:0] current_val;
    reg [WIDTH_OUT_VAL-1:0] next_val;
    reg done_flag;

    // Counters
    logic counter;

    // Initialization
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            current_val <= 0;
            counter <= 0;
            done <= 1'b0;
        end else if (enable) begin
            if (!done) begin
                if (!counter < SEQUENCE_LENGTH) begin
                    current_val = current_val + step_size;
                end else begin
                    done <= 1'b1;
                end
            end
        end
    end

    // Output assignment
    assign out_val = current_val;

endmodule
