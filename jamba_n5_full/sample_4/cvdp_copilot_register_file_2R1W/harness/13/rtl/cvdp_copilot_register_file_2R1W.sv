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

    // Internal registers and wires
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;
    integer i;

    // Clock enable signals
    wire clk_en;
    wire gated_clk;

    // Clock gating logic
    always_comb begin
        clk_en = wen1 | ren1 | ren2;
        gated_clk = (clk_en & (wen1 || ren1 || ren2));
    end

    // Register file memory
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rf_mem <= {32{1'b0}};
            rf_valid <= 0;
        end else begin
            if (wen1) begin
                rf_mem[wad1] <= din;
            end
        end
    end

    // Write Enable Latch
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) rf_valid <= 0;
        else if (wen1) rf_valid <= 1;
        else rf_valid <= 0;
    end

    // Read Data Outputs
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end else if (ren1) begin
            dout1 <= rf_mem[rad1];
        end else begin
            dout1 <= 0;
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end else if (ren2) begin
            dout2 <= rf_mem[rad2];
        end else begin
            dout2 <= 0;
        end
    end

    // Collision Detection
    always_ff @(posedge clk or negedge resetn) begin
        collision <= !resetn || (ren1 && ren2) || (wad1 == rad1) || (wad1 == rad2);
    end

    // Output default to 0
    assign dout1 = (ren1 || ren2) ? rf_mem[rad1] : 0;
    assign dout2 = (ren1 || ren2) ? rf_mem[rad2] : 0;

endmodule
