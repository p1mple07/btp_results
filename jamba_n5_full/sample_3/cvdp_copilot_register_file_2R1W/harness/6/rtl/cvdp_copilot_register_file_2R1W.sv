module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32  // Configurable data width
) (
    // Inputs
    input  logic [DATA_WIDTH-1:0] din,    // Input data
    input  logic [4:0] wad1,              // Write address
    input  logic [4:0] rad1,              // Read address 1
    input  logic [4:0] rad2,              // Read address 2
    input  logic wen1,                    // Write-enable signal
    input  logic ren1,                    // Read-enable signal 1
    input  logic ren2,                    // Read-enable signal 2
    input  logic clk,                     // Clock signal
    input  logic resetn,                  // Active-low reset

    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,   // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,   // Output data 2
    output logic collision                 // Collision flag
);

    // New BIST control signals
    output logic [1:0] test_mode;
    output logic bist_done;
    output logic bist_fail;

    // Internal registers and wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @(clk or clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // -------------------------------
    // Register File Operations
    // -------------------------------

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize all memory locations to zero
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;  // Mark all entries as invalid
        end 
        else if (wen1) begin
            rf_mem[wad1]    <= din;  // Write operation
            rf_valid[wad1]  <= 1;    // Mark written address as valid
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end 
        else if (ren1) begin
            dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
        end 
        else begin
            dout1 <= 0;
        end
    end

    // Read Data Output Logic for Port 2 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end 
        else if (ren2) begin
            dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
        end 
        else begin
            dout2 <= 0;
        end
    end

    // -------------------------------
    // Collision Detection Logic
    // -------------------------------

    // Collision Flag Logic with Original Clock (non-gated)
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end 
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
        end
    end

endmodule

// BIST Enhancement
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        test_mode <= 0;
        bist_done <= 0;
        bist_fail <= 0;
    end else begin
        if (test_mode) begin
            // BIST Sequence
            always_ff @(posedge gated_clk) begin
                if (wen1) begin
                    rf_mem[wad1] <= din;  // Write operation
                    rf_valid[wad1] <= 1;  // Mark written address as valid
                end

                always_ff @(posedge gated_clk) begin
                    if (ren1) begin
                        dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
                    end
                    else if (ren2) begin
                        dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
                    end
                end

                always_ff @(posedge gated_clk) begin
                    if (comparison_done) begin
                        bist_compare_pass <= 0;
                        bist_fail <= 0;
                        // Check if any mismatch
                        if (dout1 != rf_mem[rad1] ||
                            dout2 != rf_mem[rad2]) begin
                                    bist_fail <= 1;
                        end else begin
                                    bist_done <= 1;
                        end
                    end
                end
            end
        end
        else
            // Normal operation continues
        end
    end
end
