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
    output logic collision               // Collision flag
);

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31]; // Register file memory
    logic [DATA_WIDTH-1:0] dout1, dout2;  // Output data
    logic [31:0] rf_valid;                // Validity of each register entry
    logic en_latch;                       // Enable latch
    logic gated_clk;                      // Gated clock output

    // Enable latch generation logic
    assign en_latch = wen1 | ren1 | ren2;

    // Custom Clock Gating Logic
    assign gated_clk = en_latch;

    // Register File Memory Initialization on Reset
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_mem = {32{1'b0}}; // Initialize all memory entries to zero
            rf_valid = {32{1'b0}}; // Mark all entries as invalid
        end
        else if (wen1) begin
            rf_mem[wad1] = din; // Perform write operation
            rf_valid[wad1] = 1'b1; // Update validity
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 = 0;
        end
        else if (ren1) begin
            dout1 = rf_valid[rad1] ? rf_mem[rad1] : 0;
        end
        else begin
            dout1 = 0;
        end
    end

    // Read Data Output Logic for Port 2 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 = 0;
        end
        else if (ren2) begin
            dout2 = rf_valid[rad2] ? rf_mem[rad2] : 0;
        end
        else begin
            dout2 = 0;
        end
    end

    // Collision Detection Logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision = 0;
        end
        else begin
            // Collision detection logic
            collision = (rad1 == rad2) | (((wen1 && wad1 == rad1) || (wen1 && wad1 == rad2)) && ren1);
        end
    end

endmodule
