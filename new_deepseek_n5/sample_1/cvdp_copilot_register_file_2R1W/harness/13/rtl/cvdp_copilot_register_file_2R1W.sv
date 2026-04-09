module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] din,
    input logic [4:0] wad1,
    input logic [4:0] rad1,
    input logic [4:0] rad2,
    input logic wen1,
    input logic ren1,
    input logic ren2,
    input logic clk,
    input logic resetn
    output logic [DATA_WIDTH-1:0] dout1,
    output logic [DATA_WIDTH-1:0] dout2,
    output logic collision
);

    // Register file memory with 32 entries of DATA_WIDTH-bit words
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;                   // Validity of each register entry
    integer i;

    // Clock Gating Enable Signal: High when any read or write operation is active
    wireclk_en = wen1 | ren1 | ren2;

    // Custom Clock Gating Logic
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Enable latch generation logic
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            en_latch <= 0;
        end
    end

    // Gated clock output logic
    gated_clk = en_latch;

    // Reset and Write Operation Logic with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_valid <= 0;  // Mark all entries as invalid
        end
        else if (wen1) begin
            rf_mem[rad1] = din;
            rf_valid[rad1] = 1;
        end
    end

    // Read Data Output Logic for Port 1 with Gated Clock
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end
        else if (ren1) begin
            dout1 = rf_valid[rad1] ? rf_mem[rad1] : 0;
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
            dout2 = rf_valid[rad2] ? rf_mem[rad2] : 0;
        end
        else begin
            dout2 <= 0;
        end
    end

    // Collision Detection Logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end
        else begin
            collision = (rad1 == rad2) || (wad1 == rad1) || (wad1 == rad2);
        end
    end
endmodule