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

    // Internal registers and wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal
    wire clk_en = wen1 | ren1 | ren2;

    // Gated clock generation
    assign gated_clk = clk && en_latch;

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
            rf_mem[wad1] <= din;  // Write operation
            rf_valid[wad1] <= 1;    // Mark written address as valid
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

    // BIST Control Signals
    output logic [2:0] test_mode;
    output logic bist_done;
    output logic bist_fail;

    // BIST Logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset all registers and BIST counters
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;
            bist_done <= 0;
            bist_fail <= 0;
        end else if (test_mode) begin
            // Enter BIST mode
            bist_done <= 0;
            bist_fail <= 0;

            // Write phase
            always_comb begin
                wr_val <= {DATA_WIDTH'b0};  // Placeholder: set to 42 for testing
                for (i = 0; i < 32; i = i + 1) begin
                    rf_mem[i] <= wr_val;
                end
            end

            // Read phase
            always_comb begin
                bist_done <= 1;
                bist_fail <= 0;

                for (i = 0; i < 32; i = i + 1) begin
                    if (rf_mem[i] != 42) begin
                        bist_fail <= 1;
                        break;
                    end
                end
            end

            if (bist_fail) begin
                bist_done <= 1;
                bist_fail <= 1;
            end
        end
    end

endmodule
