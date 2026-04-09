module halfband_fir #(
    parameter LGNTAPS = 7,
    parameter IW      = 16,
    parameter TW      = 12,
    parameter OW      = IW + TW + LGNTAPS,
    parameter [LGNTAPS:0] NTAPS        = 107,
    parameter [0:0]       FIXED_TAPS   = 1'b0,
    parameter           INITIAL_COEFFS = "",
    parameter [0:0]       OPT_HILBERT  = 1'b0
) (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_tap_wr,
    input  wire [(TW-1):0] i_tap,
    input  wire i_ce,
    input  wire [(IW-1):0] i_sample,
    output reg  o_ce,
    output reg  [(OW-1):0] o_result
);

    // Remove unused parameter
    // localparam UNUSED_PARAM = 42; // Unused parameter to simulate a warning

    reg [3:0] messy_flag;
    
    reg [IW-1:0] dmem1_messy [0:DMEMSZ-1];
    reg [IW-1:0] dmem2_messy [0:DMEMSZ-1];
    
    reg [LGNMEM-1:0] write_idx, left_idx, right_idx;
    reg [LGNCOEF-1:0] tap_idx;
    reg signed [IW-1:0] sample_left, sample_right, mid_sample_messy;
    reg signed [IW:0]   sum_data;
    reg clk_en, data_en, sum_en;
    reg signed [IW+TW-1:0] mult_result;
    reg signed [OW-1:0]    acc_result;
    
    // Control wires:
    wire last_tap_warn, last_data_warn;
    reg [LGNTAPS-2:0] remaining_taps;
    
    // Remove redundant generate block for COEFF_MEM
    reg [LGNCOEF-1:0] coef_mem_messy;

    // Initialization of coef_mem_messy removed since INITIAL_COEFFS is now a parameter
    // initial coef_mem_messy = coef_mem_messy; // Removed

    // Initialize coef_mem_messy with INITIAL_COEFFS if it's not empty
    if (INITIAL_COEFFS != "") begin
        coef_mem_messy = {IW{INITIAL_COEFFS}};
    end

    // Replace generate block with a single always block
    always @(posedge i_clk) begin
        if (i_reset) begin
            write_idx <= 0;
            left_idx <= 0;
            right_idx <= 0;
            tap_idx <= 0;
            sample_left <= 0;
            sample_right <= 0;
            messy_flag <= 4'b0;
            clk_en <= 0;
            sum_data <= 0;
            mult_result <= 0;
            acc_result <= 0;
            o_ce <= 0;
        end else if (i_ce) begin
            write_idx <= write_idx + 1;
            left_idx <= write_idx;
            right_idx <= write_idx - (HALFTAPS[LGNMEM-1:0]) + 1;
            sample_left <= dmem1_messy[left_idx];
            sample_right <= dmem2_messy[right_idx];
            clk_en <= 1;
            sum_data <= sample_left + sample_right;
            mult_result <= coef_mem_messy[tap_idx[LGNCOEF-1:0]];
            acc_result <= mult_result * sum_data;
            o_ce <= 1;
        end

        // Update warnings and flags
        last_tap_warn <= remaining_taps <= 1;
        last_data_warn <= (QTRTAPS - tap_idx <= 2);
        sum_en <= data_en && !i_reset;
        messy_flag[3] <= (clk_en && !i_reset);
    end

    // Assignments to o_result moved inside always block
    always @(posedge i_clk) begin
        if (sum_en)
            o_result <= acc_result;
    end

    // Remove BAD_TaskName and DummyFunction as they are not needed
endmodule
