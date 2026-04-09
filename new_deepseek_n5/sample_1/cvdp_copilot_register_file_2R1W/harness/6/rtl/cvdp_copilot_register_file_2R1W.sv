module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32
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
    input  logic test_mode,               // BIST control signal
    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,   // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,   // Output data 2
    output logic collision,               // Collision flag
    output logic bist_done,               // BIST done flag
    output logic bist_fail,               // BIST fail flag
);

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with 32 entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wireclk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @ (clk orclk_en) begin
        if (!clk)
            en_latch <=clk_en;
    end

    // Gated clock generation
    assign gated_clk =clk && en_latch;

    // -------------------------------
    // BIST Control Logic
    // -------------------------------

    // BIST State Machine
    integer b_state = 0; // 0: INITIAL, 1: WRITE, 2: READ, 3: DONE
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            b_state = 0;
            // Initialize all memory locations to zero
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;  // Mark all entries as invalid
        end 
        else if (test_mode) begin
            case (b_state)
                0: b_state = 1; // Write phase
                1: b_state = 2; // Read phase
                2: b_state = 3; // DONE phase
            endcase
        else begin
            // Normal operation
            if (!resetn) begin
                en_latch <= 0;
            end 
            else if (wen1) begin
                rf_mem[wad1] <= din;  // Write operation
                rf_valid[wad1] <= 1; // Mark written address as valid
            end
        end
    end

    // Write Phase
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn && b_state == 1) begin
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= i; // Write known pattern
            end
            b_state = 2; // Transition to Read phase
        end
    end

    // Read Phase
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn && b_state == 2) begin
            // Read data and compare
            bist_fail <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                if (i % 4 == 0) begin
                    // Read pattern
                    rf_valid[i] <= 1;
                    dout1 <= rf_mem[i];
                    dout2 <= rf_mem[i + 1];
                end
            end
            b_state = 3; // Transition to DONE phase
        end
    end

    // Collision Detection Logic
    // -------------------------------

    // Collision Flag Logic with Original Clock (non-gated)
    always_ff @(posedgeclk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
        end
    end

endmodule