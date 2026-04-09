module cvdp_copilot_register_file_2R1W #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
) (
    input logic test_mode,
    input logic clk,
    input logic resetn,
    input logic din,
    input logic [DATA_WIDTH-1:0] wad1,
    input logic wen1,
    input logic rad1,
    input logic ren1,
    input logic ren2,
    output logic bist_done,
    output logic bist_fail
);

    // Existing declarations...

    // BIST Control and Status Signals
    logic bist_state = 0;
    logic bist_addr;
    logic bist_pattern;
    logic bist_compare_pass;

    // BIST Phases
    logic write_phase;
    logic read_phase;

    // BIST Sequence Logic
    always_comb begin
        if (test_mode) begin
            if (bist_state == 0) begin
                bist_state = 1;
                write_phase = 1;
                bist_addr = 0;
                bist_pattern = {DATA_WIDTH{1'b0}};
            end else if (bist_state == 1) begin
                bist_state = 2;
                write_phase = 1;
                bist_addr = bist_addr + 1;
                bist_pattern = {DATA_WIDTH{1'b0}};
            end else if (bist_state == 2) begin
                bist_state = 3;
                read_phase = 1;
                bist_addr = bist_addr + 1;
            end
        end
    end

    always_comb begin
        if (bist_state == 3) begin
            bist_state = 4;
            read_phase = 1;
            bist_addr = bist_addr + 1;
            bist_compare_pass = (dout1 == bist_pattern[bist_addr]) && (dout2 == bist_pattern[bist_addr]);
        end
        if (bist_state == 4) begin
            bist_state = 5;
            bist_done = 1;
            bist_fail = ~bist_compare_pass;
        end
    end

    // Existing Register File Operations...

    // Updated Collision Detection Logic to include BIST status
    always_comb begin
        if (!resetn) begin
            collision <= 0;
        end
        else begin
            collision <= (
                (ren1 && ren2 && (rad1 == rad2)) ||
                (wen1 && ren1 && (wad1 == rad1)) ||
                (wen1 && ren2 && (wad1 == rad2)) ||
                (bist_fail)
            );
        end
    end

endmodule
