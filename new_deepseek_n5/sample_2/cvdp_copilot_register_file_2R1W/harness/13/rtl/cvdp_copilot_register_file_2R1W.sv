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
    logic en_latch;    // Enable latch
    logic gated_clk;

    // Enable latch: holds the state of the original clock enable
    wire en_latch = !resetn ? (clk_en) : en_latch;

    // Gated clock: active only when any enable signal is asserted
    wire gated_clk = !resetn ? (wen1 | ren1 | ren2) : gated_clk;

    // Register file operations
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_valid <= 0;  // Initialize all entries as invalid
            rf_mem <= (1 << DATA_WIDTH) -1; // Initialize memory with all bits high
        end else if (wen1) begin
            // Write operation
            if (rad1 in 0..31 && rf_valid[rad1]) begin
                rf_mem[rad1] <= din;
                rf_valid[rad1] <= 1;
            end else begin
                rf_valid[rad1] <= 0;
            end
        end
    end

    // Read operation for port 1
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end else if (ren1) begin
            if (rad1 in 0..31 && rf_valid[rad1]) begin
                dout1 <= rf_mem[rad1];
            else begin
                dout1 <= 0;
            end
        end else begin
            dout1 <= 0;
        end
    end

    // Read operation for port 2
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end else if (ren2) begin
            if (rad2 in 0..31 && rf_valid[rad2]) begin
                dout2 <= rf_mem[rad2];
            else begin
                dout2 <= 0;
            end
        end else begin
            dout2 <= 0;
        end
    end

    // Collision detection
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end else begin
            // Collision occurs if both reads target same address or write conflicts with reads
            collision <= (rad1 == rad2) || (rad1 == rad2 & !ren1 & !ren2) || (rad1 == rad2 & !rad1 & !rad2) || (rad1 == rad2 & !rad1 & !rad2);
        end
    end
endmodule