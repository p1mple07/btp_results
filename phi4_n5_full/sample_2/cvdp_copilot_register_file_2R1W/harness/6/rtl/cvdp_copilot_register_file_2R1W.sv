module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,  // Configurable data width
    parameter DEPTH      = 32   // Number of register entries
) (
    // Inputs
    input  logic [DATA_WIDTH-1:0] din,    // Input data
    input  logic [4:0]             wad1,  // Write address
    input  logic [4:0]             rad1,  // Read address 1
    input  logic [4:0]             rad2,  // Read address 2
    input  logic                   wen1,  // Write-enable signal
    input  logic                   ren1,  // Read-enable signal 1
    input  logic                   ren2,  // Read-enable signal 2
    input  logic                   clk,   // Clock signal
    input  logic                   resetn,// Active-low reset
    input  logic                   test_mode, // BIST activation signal

    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,  // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,  // Output data 2
    output logic                   collision, // Collision flag
    output logic                   bist_done, // BIST done signal
    output logic                   bist_fail  // BIST failure signal
);

    // For a DEPTH of 32 registers, the address width is 5 bits.
    localparam ADDR_WIDTH = 5;

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with DEPTH entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:DEPTH-1];
    logic [DEPTH-1:0]      rf_valid;      // Validity flag for each register entry
    integer                 i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @ (posedge clk or posedge clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // -------------------------------
    // Normal Register File Operations
    // (Disabled when test_mode is asserted)
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
            dout1 <= (rf_valid[rad1] ? rf_mem[rad1] : {DATA_WIDTH{1'b0}});
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
            dout2 <= (rf_valid[rad2] ? rf_mem[rad2] : {DATA_WIDTH{1'b0}});
        end 
        else begin
            dout2 <= 0;
        end
    end

    // Collision Detection Logic (Disabled during test_mode)
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end 
        else if (!test_mode) begin
            collision <= ((ren1 && ren2 && (rad1 == rad2)) ||
                          (wen1 && ren1 && (wad1 == rad1)) ||
                          (wen1 && ren2 && (wad1 == rad2)));
        end
    end

    // -------------------------------
    // BIST State Machine Registers and Parameters
    // -------------------------------

    // Define BIST state encoding
    localparam integer BIST_IDLE  = 3'd0,
                      BIST_WRITE = 3'd1,
                      BIST_READ  = 3'd2,
                      BIST_DONE  = 3'd3;

    // BIST state machine registers
    logic [2:0] bist_state;              // Current BIST state
    logic [ADDR_WIDTH-1:0] bist_addr;     // Current register address index for BIST
    logic [DATA_WIDTH-1:0] read_data_reg; // Latched read data for comparison

    // -------------------------------
    // BIST Logic (Built-In Self-Test)
    // -------------------------------
    // The BIST state machine performs a write phase (writing a known pattern to each register)
    // followed by a read phase (reading back and verifying the data).
    // When test_mode is high, normal operations are disabled.
    // -------------------------------

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bist_state      <= BIST_IDLE;
            bist_addr       <= 0;
            bist_done       <= 0;
            bist_fail       <= 0;
            read_data_reg   <= {DATA_WIDTH{1'b0}};
        end 
        else begin
            if (test_mode) begin
                case (bist_state)
                    BIST_IDLE: begin
                        // Start BIST: Move to write phase and reset index
                        bist_state <= BIST_WRITE;
                        bist_addr  <= 0;
                    end

                    BIST_WRITE: begin
                        // Write a known pattern to rf_mem at the current address.
                        // The pattern is formed by placing the address value in the lower bits.
                        rf_mem[bist_addr] <= { {(DATA_WIDTH-ADDR_WIDTH){1'b0}}, bist_addr };
                        rf_valid[bist_addr] <= 1;
                        if (bist_addr == DEPTH-1)
                            bist_state <= BIST_READ;
                        else begin
                            bist_state <= BIST_WRITE;
                            bist_addr  <= bist_addr + 1;
                        end
                    end

                    BIST_READ: begin
                        // Read back the stored data and compare with the expected pattern.
                        read_data_reg <= rf_mem[bist_addr];
                        if (rf_mem[bist_addr] !== { {(DATA_WIDTH-ADDR_WIDTH){1'b0}}, bist_addr })
                            bist_fail <= 1;
                        if (bist_addr == DEPTH-1)
                            bist_state <= BIST_DONE;
                        else begin
                            bist_state <= BIST_READ;
                            bist_addr  <= bist_addr + 1;
                        end
                    end

                    BIST_DONE: begin
                        // BIST sequence complete. Assert bist_done.
                        bist_done <= 1;
                        // Remain in DONE until test_mode is deasserted.
                        if (!test_mode) begin
                            bist_state <= BIST_IDLE;
                            bist_addr  <= 0;
                            bist_done  <= 0;
                            bist_fail  <= 0;
                        end
                    end

                    default: bist_state <= BIST_IDLE;
                endcase
            end 
            else begin
                // When not in test mode, reset the BIST state machine.
                bist_state <= BIST_IDLE;
                bist_addr  <= 0;
                bist_done  <= 0;
                bist_fail  <= 0;
                read_data_reg <= {DATA_WIDTH{1'b0}};
            end
        end
    end

endmodule