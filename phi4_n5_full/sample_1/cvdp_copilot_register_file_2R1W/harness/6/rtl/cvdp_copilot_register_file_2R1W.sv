module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,  // Configurable data width
    parameter DEPTH      = 32   // Configurable register file depth
) (
    // Normal Operation Inputs
    input  logic [DATA_WIDTH-1:0] din,    // Input data
    input  logic [4:0]            wad1,   // Write address
    input  logic [4:0]            rad1,   // Read address 1
    input  logic [4:0]            rad2,   // Read address 2
    input  logic                  wen1,   // Write-enable signal
    input  logic                  ren1,   // Read-enable signal 1
    input  logic                  ren2,   // Read-enable signal 2
    input  logic                  clk,    // Clock signal
    input  logic                  resetn, // Active-low reset

    // BIST Control Signals
    input  logic                  test_mode, // Assert high to activate BIST
    output logic                  bist_done, // BIST sequence complete
    output logic                  bist_fail, // BIST failure flag

    // Normal Operation Outputs
    output logic [DATA_WIDTH-1:0] dout1,   // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,   // Output data 2
    output logic                  collision // Collision flag
);

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with DEPTH entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [DEPTH-1:0]      rf_valid;  // Validity of each register entry
    integer                 i;

    // Clock Gating Enable Signal: High when any read or write operation is active (normal ops only)
    wire clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @ (posedge clk or negedge clk) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // -------------------------------
    // BIST Internal Signals and State Machine
    // -------------------------------

    // BIST State Encoding
    localparam BIST_IDLE  = 2'd0,
               BIST_WRITE = 2'd1,
               BIST_READ  = 2'd2,
               BIST_DONE  = 2'd3;

    // BIST state register and address counter
    logic [1:0] bist_state;
    integer     bist_addr;

    // Internal registers for BIST outputs
    logic bist_done_reg;
    logic bist_fail_reg;

    // Register to capture read data during BIST read phase
    logic [DATA_WIDTH-1:0] read_data_reg;

    // BIST State Machine: Executes only when test_mode is asserted.
    // Normal operations are disabled in this mode.
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bist_state     <= BIST_IDLE;
            bist_addr      <= 0;
            bist_done_reg  <= 0;
            bist_fail_reg  <= 0;
        end 
        else if (test_mode) begin
            case (bist_state)
                BIST_IDLE: begin
                    bist_state    <= BIST_WRITE;
                    bist_addr     <= 0;
                    bist_done_reg <= 0;
                    bist_fail_reg <= 0;
                end
                BIST_WRITE: begin
                    // Write Phase: Write a known pattern (the address value) to each register location.
                    rf_mem[bist_addr] <= bist_addr[DATA_WIDTH-1:0];
                    rf_valid[bist_addr] <= 1;
                    if (bist_addr == DEPTH - 1)
                        bist_state <= BIST_READ;
                    else
                        bist_state <= BIST_WRITE;
                    bist_addr <= bist_addr + 1;
                end
                BIST_READ: begin
                    // Read Phase: Read the value and compare it with the expected pattern.
                    read_data_reg <= rf_mem[bist_addr];
                    if (read_data_reg !== bist_addr[DATA_WIDTH-1:0])
                        bist_fail_reg <= 1;
                    if (bist_addr == DEPTH - 1)
                        bist_state <= BIST_DONE;
                    else
                        bist_state <= BIST_READ;
                    bist_addr <= bist_addr + 1;
                end
                BIST_DONE: begin
                    bist_done_reg <= 1;
                end
                default: begin
                    bist_state <= BIST_IDLE;
                end
            endcase
        end
    end

    // Drive BIST outputs
    assign bist_done = bist_done_reg;
    assign bist_fail = bist_fail_reg;

    // -------------------------------
    // Normal Operation: Register File Operations (Disabled when test_mode is high)
    // -------------------------------

    // Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize all memory locations to zero
            for (i = 0; i < DEPTH; i = i + 1) begin
                rf_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            rf_valid <= 0;  // Mark all entries as invalid
        end 
        else if (!test_mode && wen1) begin
            rf_mem[wad1]    <= din;  // Write operation
            rf_valid[wad1]  <= 1;    // Mark written address as valid
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end 
        else if (!test_mode && ren1) begin
            // Output data is valid only if the register is marked valid
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

    // -------------------------------
    // Collision Detection Logic (Normal Operations only)
    // -------------------------------

    // Collision Flag Logic with Original Clock (non-gated)
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

endmodule