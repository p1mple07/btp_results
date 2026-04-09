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

    // -------------------------------
    // Internal Registers and Wires
    // -------------------------------

    // Register file memory with 32 entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Custom Clock Gating Logic
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Enable latch generation logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            en_latch <= 0;
        else
            en_latch <= clk_en;
    end

    // Gated clock output logic
    assign gated_clk = clk & en_latch;

    // -------------------------------
    // Register File Operations
    // -------------------------------

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Memory initialization on reset: clear all memory and validity flags
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= 0;
            end
            rf_valid <= 0;
        end 
        else if (wen1) begin
            // Write operation: update the memory at wad1 and mark it as valid
            rf_mem[wad1] <= din;
            rf_valid[wad1] <= 1;
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn)
            dout1 <= 0;
        else if (ren1)
            // Output data if valid; otherwise 0
            dout1 <= (rf_valid[rad1] ? rf_mem[rad1] : 0);
        else
            dout1 <= 0;
    end

    // Read Data Output Logic for Port 2 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn)
            dout2 <= 0;
        else if (ren2)
            // Output data if valid; otherwise 0
            dout2 <= (rf_valid[rad2] ? rf_mem[rad2] : 0);
        else
            dout2 <= 0;
    end

    // -------------------------------
    // Collision Detection Logic
    // -------------------------------

    // Collision Flag Logic with Original Clock (non-gated)
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            collision <= 0;
        else begin
            // Collision occurs if:
            // - Both read ports are enabled and target the same address, OR
            // - A write operation conflicts with either read port.
            if ((ren1 && ren2 && (rad1 == rad2)) ||
                (wen1 && (rad1 == wad1)) ||
                (wen1 && (rad2 == wad1)))
                collision <= 1;
            else
                collision <= 0;
        end
    end

endmodule