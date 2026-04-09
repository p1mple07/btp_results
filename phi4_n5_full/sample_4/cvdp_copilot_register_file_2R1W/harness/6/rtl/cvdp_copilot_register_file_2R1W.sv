module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 32  // Added parameter for register file depth
) (
    // Inputs
    input  logic [DATA_WIDTH-1:0] din,    // Input data
    input  logic [4:0]            wad1,   // Write address
    input  logic [4:0]            rad1,   // Read address 1
    input  logic [4:0]            rad2,   // Read address 2
    input  logic                  wen1,   // Write-enable signal
    input  logic                  ren1,   // Read-enable signal 1
    input  logic                  ren2,   // Read-enable signal 2
    input  logic                  clk,    // Clock signal
    input  logic                  resetn, // Active-low reset
    input  logic                  test_mode,  // BIST control signal: when high, normal operations are disabled

    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,  // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,  // Output data 2
    output logic                  collision,  // Collision flag
    output logic                  bist_done,  // BIST done signal
    output logic                  bist_fail   // BIST fail signal
);

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with DEPTH entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [DEPTH-1:0]      rf_valid;   // Validity of each register entry
    integer                 i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire                    clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic                   gated_clk;    // Gated clock output
    logic                   en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @(posedge clk or posedge clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // -------------------------------
    // Normal Operations (Disabled in Test Mode)
    // -------------------------------

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize all memory locations to zero
            for (i = 0; i < DEPTH; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;  // Mark all entries as invalid
        end 
        else if (!test_mode && wen1) begin
            rf_mem[wad1] <= din;    // Write operation
            rf_valid[wad1] <= 1;    // Mark written address as valid
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end 
        else if (!test_mode && ren1) begin
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
        else if (!test_mode && ren2) begin
            dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
        end 
        else begin
            dout2 <= 0;
        end
    end

    // Collision Detection Logic (operates only when not in test mode)
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end 
        else if (!test_mode) begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
        end
    end

    // -------------------------------
    // Built-In Self-Test (BIST) Logic
    // -------------------------------

    // BIST state machine states
    localparam BIST_IDLE   = 2'b00;
    localparam BIST_WRITE  = 2'b01;
    localparam BIST_READ   = 2'b10;
    localparam BIST_DONE   = 2'b11;

    // BIST state registers
    logic [1:0] bist_state;
    // Using an integer for the register address counter
    integer bist_addr;
    // Register to hold the read data during BIST read phase
    logic [DATA_WIDTH-1:0] read_data_reg;
    // Internal registers for BIST done and fail flags
    logic bist_done_reg, bist_fail_reg;

    // Connect internal BIST flags to outputs
    assign bist_done = bist_done_reg;
    assign bist_fail = bist_fail_reg;

    // BIST state machine: Executes when test_mode is asserted.
    // It performs a write phase (writing a known pattern to every register)
    // followed by a read phase (verifying the stored data against the expected pattern).
    // If any mismatch is detected, bist_fail is flagged.
    // Once all registers are verified, bist_done is asserted.
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bist_state   <= BIST_IDLE;
            bist_addr    <= 0;
            bist_done_reg<= 0;
            bist_fail_reg<= 0;
        end 
        else if (!test_mode) begin
            // When not in test mode, reset BIST state machine
            bist_state   <= BIST_IDLE;
            bist_done_reg<= 0;
            bist_fail_reg<= 0;
        end 
        else begin
            case (bist_state)
                BIST_IDLE: begin
                    // Start BIST write phase
                    bist_state   <= BIST_WRITE;
                    bist_addr    <= 0;
                end
                BIST_WRITE: begin
                    // Write Phase: Write a known pattern to rf_mem[bist_addr]
                    // Pattern chosen: { {(DATA_WIDTH-5){1'b0}}, bist_addr }
                    rf_mem[bist_addr] <= { {(DATA_WIDTH-5){1'b0}}, bist_addr };
                    rf_valid[bist_addr] <= 1;
                    bist_addr <= bist_addr + 1;
                    if (bist_addr == DEPTH - 1)
                        bist_state <= BIST_READ;
                    else
                        bist_state <= BIST_WRITE;
                end
                BIST_READ: begin
                    // Read Phase: Read back the data and verify it against the expected pattern
                    // Expected pattern is the same as written: { {(DATA_WIDTH-5){1'b0}}, bist_addr }
                    logic [DATA_WIDTH-1:0] expected;
                    expected = { {(DATA_WIDTH-5){1'b0}}, bist_addr };
                    logic [DATA_WIDTH-1:0] temp;
                    temp = rf_mem[bist_addr];
                    read_data_reg <= temp;
                    if (temp !== expected)
                        bist_fail_reg <= 1;
                    bist_addr <= bist_addr + 1;
                    if (bist_addr == DEPTH - 1)
                        bist_state <= BIST_DONE;
                    else
                        bist_state <= BIST_READ;
                end
                BIST_DONE: begin
                    bist