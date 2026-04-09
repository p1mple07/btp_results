// ... (previous module content)

// Inputs
input logic test_mode; // BIST control signal

// Outputs
output logic bist_done; // Indicates BIST completion
output logic bist_fail; // Flags BIST failure

// BIST internal signals
logic [DATA_WIDTH-1:0] bist_pattern; // Known pattern for BIST
logic [DATA_WIDTH-1:0] read_data; // Data read during BIST
logic [DATA_WIDTH-1:0] expected_pattern; // Expected pattern for BIST
logic bist_compare_pass; // Flag for BIST comparison result

// BIST phase logic
always_ff @(posedge gated_clk or negedge resetn) begin
    if (!resetn) begin
        // Initialize BIST signals
        bist_pattern = {DATA_WIDTH{1'b0}};
        read_data = {DATA_WIDTH{1'b0}};
        expected_pattern = {DATA_WIDTH{1'b0}};
        bist_compare_pass = 1'b0;
    end 
    else if (test_mode) begin
        // Write Phase
        if (wen1) begin
            rf_mem[wad1] = bist_pattern;
            rf_valid[wad1] = 1;
        end

        // Read Phase
        if (ren1) begin
            read_data = rf_mem[rad1];
        end

        expected_pattern = bist_pattern;

        // Comparison Phase
        bist_compare_pass = (read_data == expected_pattern);

        // Check for BIST failure
        if (!bist_compare_pass) begin
            bist_fail = 1;
        end

        // Transition to next BIST phase (READ phase for next address)
        // This example assumes sequential addressing for simplicity
        if (rad1 < 31) begin
            rad1 <= rad1 + 1;
        end
    end
end

// ... (rest of the module content)

// Update the outputs to include BIST status
assign bist_done = bist_compare_pass && !bist_fail;
assign bist_fail = bist_fail;

endmodule
