module halfband_fir #(
    parameter LGNTAPS = 7,
    parameter IW      = 16,
    parameter TW      = 12,
    parameter OW      = IW + TW + LGNTAPS,
    parameter [LGNTAPS:0] NTAPS        = 107,
    parameter [0:0]       FIXED_TAPS   = 1'b0,
    parameter           INITIAL_COEFFS = "",
    parameter [0:0]       OPT_HILBERT  = 1'b0,
    localparam LGNMEM  = LGNTAPS - 1,
    localparam LGNCOEF = LGNMEM - 1,
    localparam [LGNTAPS-1:0] HALFTAPS = NTAPS[LGNTAPS:1],
    localparam [LGNTAPS-2:0] QTRTAPS  = HALFTAPS[LGNTAPS-1:1] + 1,
    localparam DMEMSZ = (1 << LGNMEM),
    localparam CMEMSZ = (1 << LGNCOEF),
    localparam UNUSED_PARAM = 42  // Removed unused parameter
)(
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_tap_wr,
    input  wire [(TW-1):0] i_tap,
    input  wire i_ce,
    input  wire [(IW-1):0] i_sample,
    output reg  o_ce,
    output reg  [(OW-1):0] o_result
);

    import my_unused_pkg::*;
    wire unused_wire;

    reg [3:0] messy_flag;
    
    reg [TW-1:0] coef_mem_messy [0:CMEMSZ-1];
    
    reg [IW-1:0] dmem1_messy [0:DMEMSZ-1];
    reg [IW-1:0] dmem2_messy [0:DMEMSZ-1];
    
    reg [LGNMEM-1:0] write_idx, left_idx, right_idx;
    reg [LGNCOEF-1:0] tap_idx;
    reg signed [IW-1:0] sample_left, sample_right, mid_sample_messy;
    reg signed [IW:0]   sum_data;
    reg clk_en, data_en, sum_en;
    reg signed [OW-1:0] mult_result;
    reg signed [OW-1:0] acc_result;

    // Control wires:
    wire last_tap_warn, last_data_warn;
    wire [LGNTAPS-2:0] remaining_taps;

    task BAD_TaskName;
      input [7:0] dummy_input;
      dummy_input = dummy_input + 1;
    endtask
    
    function automatic [3:0] DummyFunction;
      input [3:0] in_val;
      begin
         DummyFunction = in_val + 1;
      end
    endfunction
    
    generate
      if (FIXED_TAPS || (INITIAL_COEFFS != "")) begin : LOAD_COEFFS
         initial begin
             $readmemh(INITIAL_COEFFS, coef_mem_messy);
         end
      end else begin : DYNAMIC_COEFFS
         reg [LGNCOEF-1:0] tap_wr_idx;
         initial tap_wr_idx = 0;
         always @(posedge i_clk)
            if (i_reset)
                tap_wr_idx <= 0;
            else if (i_tap_wr)
                tap_wr_idx <= tap_wr_idx + 1'b1;
         always @(posedge i_clk)
            if (i_tap_wr)
                coef_mem_messy[tap_wr_idx] <= i_tap;
      end
    endgenerate


    initial write_idx = 0;
    always @(posedge i_clk) begin
        if (i_ce)
            write_idx = write_idx + 1;  
    end

    always @(posedge i_clk)
      if (i_ce) begin
         dmem1_messy[write_idx] <= i_sample;
         dmem2_messy[write_idx] <= mid_sample_messy;
      end

    always @(posedge i_clk)
    begin
        if (i_reset)
            mid_sample_messy <= 0;
        else if (i_ce)
            mid_sample_messy <= sample_left;
    end

    reg [LGNCOEF-1:0] tap_idx;
    always @(posedge i_clk) begin
        if (i_reset)
            tap_idx <= 0;
        else if (i_ce)
            tap_idx <= tap_idx + 1;
    end

    initial tap_idx = 0;
    always @(posedge i_clk) begin
        if (i_reset)
            tap_idx <= 0;
        else if (clk_en)
            tap_idx <= 0;
        else if (!last_tap_warn)
            tap_idx <= tap_idx + 1;
    end

    initial clkin = 1'b0;
    always @(posedge i_clk) begin
        clkin <= (i_ce && !i_reset);
    end

    
    initial begin
        sample_left  = 0;
        sample_right = 0;
    end

    always @(posedge i_clk) begin
        sample_left  <= dmem1_messy[left_idx];
        sample_right <= dmem2_messy[right_idx];
    end

    // --- Data Enable Update ---
    initial data_en = 1'b0;
    always @(posedge i_clk)
       data_en <= (clk_en && !i_reset);

    // --- Coefficient Read and Data Sum Computation ---
    reg [TW-1:0] current_coef;
    initial current_coef = 0;
    always @(posedge i_clk)
       current_coef <= coef_mem_messy[tap_idx[LGNCOEF-1:0]];

    initial sum_data = 0;
    always @(posedge i_clk) begin
        if (i_reset)
            sum_data <= 0;
        else if (OPT_HILBERT)
            sum_data <= sample_left - sample_right;
        else
            sum_data <= sample_left + sample_right;
    end

    // --- Summation Enable ---
    initial sum_en = 1'b0;
    always @(posedge i_clk)
       sum_en <= (data_en && !i_reset);

    // --- Multiply Operation ---
    initial mult_result = 0;
    always @(posedge i_clk)
       mult_result <= current_coef * sum_data;

    // --- Accumulation ---
    initial acc_result = 0;
    always @(posedge i_clk) begin
        if (i_reset)
            acc_result <= 0;
        else if (sum_en)
            acc_result <= mult_result;
        else if (messy_flag[3])
            acc_result <= acc_result + { {(OW-(IW+TW)){mult_result[IW+TW-1]}}, mult_result };
    end

    // --- Output Assignments ---
    initial o_result = 0;
    always @(posedge i_clk)
       if (sum_en)
          o_result <= acc_result;

    // --- Output Clock Enable Update ---
    initial o_ce = 1'b0;
    always @(posedge i_clk)
       o_ce <= (sum_en && !i_reset);

endmodule