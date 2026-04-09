module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
) (
    input logic test_mode,
    input logic clk,
    input logic resetn,
    input logic din,
    input logic [DATA_WIDTH-1:0] wad1,
    input logic wen1,
    input logic rad1,
    input logic rad2,
    input logic ren1,
    input logic ren2,
    output logic dout1,
    output logic dout2,
    output logic collision,
    output logic bist_done,
    output logic bist_fail
);

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [DEPTH-1:0] rf_valid;
    integer i;
    logic [DATA_WIDTH-1:0] bist_pattern;
    logic [DATA_WIDTH-1:0] read_data_reg, expected_pattern_reg;
    logic bist_compare_pass, bist_compare_fail;

    // Clock Gating Enable Signal: High when any read or write operation is active
    logic clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @ (clk or clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;
        end else if (wen1) begin
            rf_mem[wad1]    <= din;
            rf_valid[wad1]  <= 1;
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end else if (ren1) begin
            dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
        end else begin
            dout1 <= 0;
        end
    end

    // Read Data Output Logic for Port 2 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end else if (ren2) begin
            dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
        end else begin
            dout2 <= 0;
        end
    end

    // -------------------------------
    // Collision Detection Logic
    // -------------------------------

    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
        end
    end

    // Built-In Self-Test (BIST) Logic
    always @(posedge gated_clk or negedge resetn) begin
        if (!resetn && test_mode) begin
            bist_done <= 0;
            bist_fail <= 0;

            // Write Phase
            bist_pattern = din;
            for (i = 0; i < DEPTH; i = i + 1) begin
                rf_mem[i] <= bist_pattern;
                rf_valid[i] <= 1;
            end

            // Read Phase
            for (i = 0; i < DEPTH; i = i + 1) begin
                read_data_reg = rf_mem[i];
                expected_pattern_reg = bist_pattern;
                bist_compare_pass = (read_data_reg == expected_pattern_reg) ? 1 : 0;

                if (!bist_compare_pass) begin
                    bist_fail <= 1;
                    bist_done <= 1;
                    return;
                end
            end

            bist_done <= 1;
        end
    end

endmodule
