// Additional Inputs for BIST
input logic test_mode;

// BIST-related outputs
output logic bist_done, bist_fail;

// BIST Control Signals
logic [DATA_WIDTH-1:0] bist_pattern [0:DEPTH-1];
logic [DATA_WIDTH-1:0] expected_pattern [0:DEPTH-1];
logic read_data_reg [0:DEPTH-1];
logic comparison_result [0:DEPTH-1];

// BIST Process
always_ff @(posedge gated_clk or negedge resetn) begin
    if (!resetn) begin
        // Initialize BIST control signals
        bist_done <= 0;
        bist_fail <= 0;
        
        // Set BIST pattern
        for (int i = 0; i < DEPTH; i = i + 1) begin
            bist_pattern[i] <= {DATA_WIDTH{1'b0}};
            expected_pattern[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if (test_mode) begin
        // Write Phase
        for (int i = 0; i < DEPTH; i = i + 1) begin
            if (wen1 && wad1 == i) begin
                rf_mem[wad1] <= bist_pattern[i];
                rf_valid[wad1] <= 1;
            end
            bist_done <= 0;
        end
        
        // Read Phase
        for (int i = 0; i < DEPTH; i = i + 1) begin
            if (ren1 && rad1 == i) begin
                read_data_reg[i] <= rf_mem[rad1];
            end
        end
        
        // Comparison Phase
        for (int i = 0; i < DEPTH; i = i + 1) begin
            comparison_result[i] <= ((read_data_reg[i] == expected_pattern[i]) ? 1'b1 : 1'b0);
            bist_done <= (i == (DEPTH - 1)) ? 1'b1 : bist_done;
        end
        
        // Check for any mismatch
        bist_fail <= (0 == (1'b0 && comparison_result));
    end
end

// Modify the existing output logic to include bist_done and bist_fail
always_ff @(posedge gated_clk or negedge resetn) begin
    if (!resetn) begin
        dout1 <= 0;
        dout2 <= 0;
        collision <= 0;
    end else begin
        dout1 <= (ren1 ? (rf_valid[rad1] ? rf_mem[rad1] : 0) : 0);
        dout2 <= (ren2 ? (rf_valid[rad2] ? rf_mem[rad2] : 0) : 0);
        collision <= (
            (ren1 && ren2 && (rad1 == rad2)) ||
            (wen1 && ren1 && (wad1 == rad1)) ||
            (wen1 && ren2 && (wad1 == rad2))
        );
    end
end
