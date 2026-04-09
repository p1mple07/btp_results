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

    // Internal Registers and Wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wire clk_en = wen1 | ren1 | ren2;

    // Custom Clock Gating Logic
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Enable latch generation logic: latch the enable signal on posedge clk
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            en_latch <= 0;
        else
            en_latch <= clk_en;
    end

    // Gated clock output logic: generate gated clock when enable latch is high
    assign gated_clk = clk & en_latch;

    // -------------------------------
    // Register File Operations
    // -------------------------------

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize all registers and mark entries as invalid
            rf_valid <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                rf_mem[i] <= 0;
            end
        end 
        else if (wen1) begin
            // Write operation: update the memory and mark the entry as valid
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
            // Conditional read operation: output valid data if available
            dout1 <= (rf_valid[rad1]) ? rf_mem[rad1] : 0;
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
            // Output data if valid, otherwise default to 0
            dout2 <= (rf_valid[rad2]) ? rf_mem[rad2] : 0;
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
            // Collision occurs if both read ports target the same address
            // or if a write operation conflicts with either read port.
            if ((rad1 == rad2) || (wen1 && (wad1 == rad1)) || (wen1 && (wad1 == rad2))) begin
                collision <= 1;
            end else begin
                collision <= 0;
            end
        end
    end

endmodule