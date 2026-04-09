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
    input logic resetn,
    output logic [DATA_WIDTH-1:0] dout1,
    output logic [DATA_WIDTH-1:0] dout2,
    output logic collision
);

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
        if (!resetn) begin
            en_latch <= 0;
        else
            en_latch <= en_latch;
        end
    end

    // Gated clock output logic
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            gated_clk <= 0;
        else
            gated_clk <= en_latch;
        end
    end

    // Register file initialization on reset
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_valid <= 0;  // Mark all entries as invalid
        end
    end

    // Write operation logic
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn && wen1) begin
            // Write data to memory
            rf_mem[rad1] <= din;
            // Update validity
            rf_valid[rad1] <= 1;
        end
    end

    // Read operation logic for port 1
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        else if (ren1) begin
            if (rad1 < 32 && rf_valid[rad1]) begin
                dout1 <= rf_mem[rad1];
            else
                dout1 <= 0;
            end
        end
    end

    // Read operation logic for port 2
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        else if (ren2) begin
            if (rad2 < 32 && rf_valid[rad2]) begin
                dout2 <= rf_mem[rad2];
            else
                dout2 <= 0;
            end
        end
    end

    // Collision detection logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        else begin
            // Collision if both reads target same address or write conflicts with reads
            collision <= (rad1 == rad2) || (rad1 == rad2 & wad1 == rad1) || (rad1 == rad2 & wad1 == rad2);
        end
    end
endmodule