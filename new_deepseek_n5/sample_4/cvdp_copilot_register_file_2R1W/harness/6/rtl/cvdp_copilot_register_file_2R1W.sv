module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
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

    // BIST Control Signals
    input  logic test_mode,               // Activate BIST when high
    output logic bist_done,               // Signal for BIST completion
    output logic bist_fail,               // Signal for BIST failure
);

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with 32 entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [DEPTH-1:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

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

    // BIST Control Logic
    always begin
        if (test_mode) begin
            // Write Phase
            always_ff @(posedge gated_clk or negedge resetn) begin
                if (!resetn) begin
                    // Initialize all memory locations to zero
                    for (i = 0; i < DEPTH; i = i + 1) begin
                        rf_mem[i] <= {DATA_WIDTH{1'b0}};
                    end
                    rf_valid <= 0;  // Mark all entries as invalid
                end 
                else if (wen1) begin
                    rf_mem[wad1]    <= din;  // Write operation
                    rf_valid[wad1]  <= 1;    // Mark written address as valid
                end
            end

            // Read Phase
            always_ff @(posedge gated_clk or negedge resetn) begin
                if (!resetn) begin
                    dout1 <= 0;
                    dout2 <= 0;
                    bist_done <= 0;
                    bist_fail <= 0;
                end 
                else if (ren1) begin
                    dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
                end 
                else if (ren2) begin
                    dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
                end 
                else begin
                    dout1 <= 0;
                    dout2 <= 0;
                end
            end
        end else begin
            // Normal operation
            always_ff @(posedge gated_clk or negedge resetn) begin
                if (!resetn) begin
                    dout1 <= 0;
                    dout2 <= 0;
                end 
                else if (ren1) begin
                    dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
                end 
                else if (ren2) begin
                    dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
                end 
                else begin
                    dout1 <= 0;
                    dout2 <= 0;
                end
            end
        end
    end

    // -------------------------------
    // Register File Operations
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