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

    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    wire clk_en = wen1 | ren1 | ren2;

    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    assign gated_clk = clk_en;

    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            gated_clk <= 1'b0;
        end else begin
            gated_clk <= clk_en;
        end
    end

    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_valid <= 0;  // Mark all entries as invalid
        end
        else if (wen1) begin
            if (!rene1 && !rene2) begin
                rf_mem[wad1] <= din;
                rf_valid[wad1] <= 1;
            end
        end
    end

    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end else if (ren1) begin
            if (rf_valid[rad1]) begin
                dout1 <= rf_mem[rad1];
            end else dout1 <= 0;
        end
    end

    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end else if (ren2) begin
            if (rf_valid[rad2]) begin
                dout2 <= rf_mem[rad2];
            end else dout2 <= 0;
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end else begin
            collision = (ren1 == ren2) || (wad1 == rad1) || (wad1 == rad2);
        end
    end

endmodule
