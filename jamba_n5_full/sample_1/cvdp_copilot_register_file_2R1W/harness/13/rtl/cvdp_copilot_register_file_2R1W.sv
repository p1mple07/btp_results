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

    // Insert code here for the Enable latch generation logic
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            en_latch <= 0;
        end else begin
            en_latch <= wen1 | ren1 | ren2;
        end
    end

    // Insert code here for the Gated clock output logic
    assign gated_clk = clk_en & en_latch;

    // -------------------------------
    // Register File Operations
    // -------------------------------

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize all memory entries to 0
            rf_mem[0:31] <= 0;
            rf_valid <= 0;
        end
        else if (wen1) begin
            // Write operation and validity update
            rf_mem[wad1] <= din;
            rf_valid[wad1] <= 1;
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end
        else if (ren1) begin
            // Conditional read operation on port 1
            if (rad1 == wad1) begin
                dout1 <= rf_mem[rad1];
            end
            else begin
                dout1 <= 0;
            end
        end
    end

    // Read Data Output Logic for Port 2 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end
        else if (ren2) begin
            if (rad2 == wad1 || rad2 == wad2) begin
                // Check collision: if same address as write or read
                if (rad2 == wad1) dout2 <= rf_mem[rad2];
                else if (rad2 == wad2) dout2 <= rf_mem[rad2];
                else dout2 <= 0;
            end
            else dout2 <= 0;
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
            // Check for read‑to‑read and write‑to‑read collisions
            collision <= (ren1 && (rad1 == rad2 && wad1 == rad1)) ||
                        (ren2 && (rad2 == rad1 && wad2 == rad2));
        end
    end

endmodule
