
// Inside the module arithmetic_progression_generator
// Modify the localparam definition to handle SEQUENCE_LENGTH = 0
localparam WIDTH_OUT_VAL = (SEQUENCE_LENGTH > 0) ? $clog2(SEQUENCE_LENGTH) + DATA_WIDTH : DATA_WIDTH;

// In the always_ff procedural block, after reset condition
if (!resetn) begin
    current_val <= 0;
    counter <= 0;
    done <= 1'b0;
end
else if (enable) begin
    if (SEQUENCE_LENGTH <= 0) begin
        current_val <= start_val; // Initialize with start value
        done <= 1'b0; // Ensure done flag does not assert
    end else if (counter == 0) begin
        current_val <= start_val; // Initialize with start value
    end else begin
        current_val <= current_val + step_size; // Compute next term
    end

    if (SEQUENCE_LENGTH > 0 && counter < SEQUENCE_LENGTH - 1) begin
        counter <= counter + 1; // Increment counter
    end else begin
        done <= 1'b1; // Mark completion
    end
end
