module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
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

    // BIST Control Signals
    input logic test_mode,                // Activate BIST when asserted high
    // Outputs
    output logic [DATA_WIDTH-1:0] dout1,   // Output data 1
    output logic [DATA_WIDTH-1:0] dout2,   // Output data 2
    output logic collision,               // Collision flag
    output logic bist_done,               // BIST completion flag
    output logic bist_fail,                // BIST failure flag
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

    // Clock Gating Logic (Integrated from cgate module)
    logic gated_clk;    // Gated clock output
    logic en_latch;     // Enable latch

    // Latch to hold the enable signal when clk is low
    always @ (clk or clk_en) begin
        if (!clk)
            en_latch <= clk_en;
    end

    // Gated clock generation
    assign gated_clk = clk && en_latch;

    // BIST Control Signals
    logic test_state;    // BIST state: IDLE, WRITE, READ, DONE
    logic write complete; // Complete write phase
    logic read complete; // Complete read phase

    // BIST Initialization
    always begin
        test_state <= IDLE;
        write complete <= 0;
        read complete <= 0;
    end

    // -------------------------------
    // BIST Write Phase
    // -------------------------------

    // Write Phase
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn && test_mode) begin
            case (test_state)
                IDLE: test_state <= WRITE;
                WRITE: begin
                    // Write known pattern
                    for (i = 0; i < DEPTH; i = i + 1) begin
                        rf_mem[i] <= (i % 4) ? 1'b0 : 0;
                    end
                    rf_valid <= 0;
                    write complete <= 1;
                    test_state <= READ;
                end
            end
        end
    end

    // Read Phase
    always_ff @(posedge gated_clk or negedge resetn) begin
        if (!resetn && test_mode && test_state == READ) begin
            read complete <= 0;
            collision <= 0;
            bist_fail <= 0;
            case (test_state)
                IDLE: test_state <= DONE;
                DONE: begin
                    // Read data and compare
                    if (rad1 == rad2) begin
                        collision <= (dout1 == dout2);
                    end
                    else begin
                        collision <= 1;
                    end
                    if (bist_fail) begin
                        $finish;
                    end
                end
                DONE: test_state <= DONE;
            end
        end
    end

    // -------------------------------
    // Collision Detection Logic
    // -------------------------------

    // Collision Flag Logic with Original Clock (non-gated)
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            collision <= 0;
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||          // Both reads to the same address
                (wen1 && ren1 && (wad1 == rad1)) ||          // Write and read to the same address
                (wen1 && ren2 && (wad1 == rad2))             // Write and read to the same address
            );
        end
    end

endmodule