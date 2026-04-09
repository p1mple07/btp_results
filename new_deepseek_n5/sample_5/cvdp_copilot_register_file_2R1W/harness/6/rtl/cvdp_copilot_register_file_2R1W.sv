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
    input  logic test_mode,                // BIST control signal
    input  logic resetn,                  // Active-low reset

    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,   // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,   // Output data 2
    output logic collision,                // Collision flag
    output logic bist_done,                // BIST done signal
    output logic bist_fail,                // BIST fail signal

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer bist_phase;                        // BIST phase state
);

    // -------------------------------
    // Internal Clock Gating Logic
    // -------------------------------

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

    // -------------------------------
    // BIST Control Logic
    // -------------------------------

    // BIST State Machine
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            bist_phase <= 0; // IDLE state
        end else if (test_mode) begin
            case (bist_phase)
                0: // IDLE
                    bist_phase <= 1; // WRITE phase
                    rad1 <= 0;
                    rad2 <= 0;
                    wad1 <= 0;
                1: // WRITE phase
                    // Write phase: Write pattern to all addresses
                    for (integer i = 0; i < DATA_WIDTH; i = i + 1) begin
                        rf_mem[i] <= (i & 1) ? 1'b1 : 0; // Simple pattern: 0,1,2,3...
                        rf_valid[i] <= 1;
                    end
                    bist_phase <= 2; // transition to READ phase
                2: // READ phase
                    // Read phase: Read and compare
                    for (integer i = 0; i < DATA_WIDTH; i = i + 1) begin
                        dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
                        dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
                        if (rad1 == rad2) begin
                            collision <= 1;
                        end
                    end
                    bist_phase <= 3; // DONE state
            end
        end
    end

    // BIST Done and Fail Signals
    always_ff @ (posedge gated_clk or negedge resetn) begin
        if (bist_phase == 3) begin
            bist_done <= 1;
            bist_fail <= 0;
        end else if (bist_phase == 2) begin
            // Collision detection
            if (collision) begin
                bist_fail <= 1;
                bist_done <= 1;
            end else begin
                bist_fail <= 0;
                bist_done <= 1;
            end
        end
    end

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
            rf_mem[wad1] <= din;  // Write operation
            rf_valid[wad1] <= 1; // Mark written address as valid
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