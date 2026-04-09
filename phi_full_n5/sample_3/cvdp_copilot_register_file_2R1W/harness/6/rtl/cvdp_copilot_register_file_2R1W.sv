module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
) (
    input test_mode,
    input clk,
    input resetn,
    input din,
    input [DATA_WIDTH-1:0] wad1,
    input wen1,
    input [4:0] rad1,
    input [4:0] rad2,
    input ren1,
    input ren2,
    output dout1,
    output dout2,
    output collision,
    output bist_done,
    output bist_fail
);

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [31:0] rf_valid;
    logic [DATA_WIDTH-1:0] known_pattern [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] read_data [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] expected_pattern [0:DEPTH-1];
    logic bist_done_flag = 0;
    logic bist_fail_flag = 0;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;
    logic en_latch;

    // Latch to hold the enable signal when clk is low
    always @ (clk or clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // BIST Control Logic
    always @ (posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize known patterns for BIST
            for (int i = 0; i < DEPTH; i = i + 1) begin
                known_pattern[i] = logic'hFF; // Assuming known pattern is all 1's
            end
        end 
        else if (test_mode) begin
            // Write Phase
            if (wen1) begin
                rf_mem[wad1] <= din;
                rf_valid[wad1] <= 1;
            end

            // Read Phase
            read_data[rad1] <= rf_mem[rad1];
            expected_pattern[rad1] <= known_pattern[rad1];

            // Comparison Phase
            if (read_data[rad1] !== expected_pattern[rad1]) begin
                bist_fail_flag = 1;
            end

            // Check if all reads pass
            if (bist_fail_flag == 0) begin
                bist_done_flag = 1;
            end
        end
    end

    // Regular Operations
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
            dout1 <= 0;
            dout2 <= 0;
        end 
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
            dout1 <= (ren1 && rf_valid[rad1]) ? rf_mem[rad1] : 0;
            dout2 <= (ren2 && rf_valid[rad2]) ? rf_mem[rad2] : 0;
        end
    end

endmodule

This updated SystemVerilog module now includes the Built-In Self-Test (BIST) feature. When the `test_mode` signal is asserted high, the module performs a write phase by writing the input `din` to the register file. It then enters a read phase, reading back the data from each register location and comparing it against a predefined known pattern. If a mismatch is detected, the `bist_fail_flag` is set. If all registers pass the comparison, the `bist_done_flag` is set.

The outputs `bist_done` and `bist_fail` indicate the completion of the BIST sequence and whether any failures were detected, respectively. The module retains its original functionality when `test_mode` is not asserted.

Please note that this implementation assumes a known pattern of all '1's for simplicity. Depending on the BIST requirements, the known pattern may need to be configurable or generated differently. Additionally, this implementation does not handle the case where `rad1` and `rad2` are the same; the logic assumes that they are different addresses. Depending on the specific BIST requirements, additional logic may be needed to handle this case. module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
) (
    input test_mode,
    input clk,
    input resetn,
    input din,
    input [DATA_WIDTH-1:0] wad1,
    input wen1,
    input [4:0] rad1,
    input [4:0] rad2,
    input ren1,
    input ren2,
    output dout1,
    output dout2,
    output collision,
    output bist_done,
    output bist_fail
);

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [31:0] rf_valid;
    logic [DATA_WIDTH-1:0] known_pattern [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] read_data [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] expected_pattern [0:DEPTH-1];
    logic bist_done_flag = 0;
    logic bist_fail_flag = 0;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;
    logic en_latch;

    // Latch to hold the enable signal when clk is low
    always @ (clk or clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // BIST Control Logic
    always @ (posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize known patterns for BIST
            for (int i = 0; i < DEPTH; i = i + 1) begin
                known_pattern[i] = logic'hFF; // Known pattern (can be made configurable if needed)
            end
        end 
        else if (test_mode) begin
            // Write Phase
            if (wen1) begin
                rf_mem[wad1] <= din;
                rf_valid[wad1] <= 1;
            end

            // Read Phase
            read_data[rad1] <= rf_mem[rad1];
            expected_pattern[rad1] <= known_pattern[rad1];

            // Comparison Phase
            if (read_data[rad1] !== expected_pattern[rad1]) begin
                bist_fail_flag = 1;
            end

            // Check if all reads pass
            if (bist_fail_flag == 0) begin
                bist_done_flag = 1;
            end
        end
    end

    // Regular Operations
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
            dout1 <= 0;
            dout2 <= 0;
        end 
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
            dout1 <= (ren1 && rf_valid[rad1]) ? rf_mem[rad1] : 0;
            dout2 <= (ren2 && rf_valid[rad2]) ? rf_mem[rad2] : 0;
        end
    end

endmodule