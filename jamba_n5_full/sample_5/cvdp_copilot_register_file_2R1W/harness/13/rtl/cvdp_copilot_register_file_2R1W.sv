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

    // Internal registers and signals
    logic [DATA_WIDTH-1:0] rf_mem [0:31];
    logic [31:0] rf_valid;
    integer i;

    // Clock gating enable
    wire clk_en = wen1 | ren1 | ren2;

    // Clock gating logic
    logic gated_clk;
    assign gated_clk = clk_en && (wen1 || ren1 || ren2);

    // Custom clock gating
    logic en_latch;
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            en_latch <= 0;
        end else begin
            en_latch <= clk;
        end
    end

    // Reset and initialise all registers
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            rf_valid <= 0;
            rf_mem <= 32'h0000_0000;
        end
    end

    // Read Port 1
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout1 <= 0;
        end
        else if (ren1) begin
            if (ren1 && (wad1 == rf_mem[rad1])) begin
                if (ren1 && (dout1 != 0)) begin
                    dout1 <= rf_valid[rad1] ? rf_mem[rad1] : 0;
                end;
            end
        end
    end

    // Read Port 2
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn) begin
            dout2 <= 0;
        end
        else if (ren2) begin
            if (ren2 && (wad2 == rf_mem[rad2])) begin
                if (ren2 && (dout2 != 0)) begin
                    dout2 <= rf_valid[rad2] ? rf_mem[rad2] : 0;
                end;
            end
        end
    end

    // Collision detection
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        end
        else begin
            collision = (ren1 && ren2) && (rf_valid[rad1] && rf_valid[rad2]) && (rf_mem[rad1] == rf_mem[rad2]);
        end
    end

endmodule
