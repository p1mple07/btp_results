module halfband_fir #(
    parameter LGNTAPS = 7,
    parameter IW      = 16,
    parameter TW      = 12,
    parameter OW      = IW + TW + LGNTAPS,
    parameter [LGNTAPS-1:0] NTAPS        = 107,
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

    reg [3:0] messy_flag;
    reg [TW-1:0] coef_mem_messy [0:CMEMSZ-1];
    reg [IW-1:0] dmem1_messy [0:DMEMSZ-1];
    reg [IW-1:0] dmem2_messy [0:DMEMSZ-1];
    reg [LGNMEM-1:0] write_idx, left_idx, right_idx;
    reg [LGNCOEF-1:0] tap_idx;
    reg signed [IW-1:0] sample_left, sample_right, mid_sample_messy;
    reg signed [OW-1:0] sum_data;
    reg clk_en, data_en, sum_en;
    reg signed [IW+TW-1:0] mult_result;
    reg signed [OW-1:0]    acc_result;

    // Control wires
    reg [LGNTAPS-2:0] remaining_taps;
    reg last_tap_warn, last_data_warn;

    // Task to simulate unused parameter
    task BAD_TaskName;
      input [7:0] dummy_input;
      // Unused parameter logic can be removed or reassigned
      // dummy_input = dummy_input + 1;
    endtask

    function automatic [3:0] DummyFunction;
      input [3:0] in_val;
      // Unused function logic can be removed
      // begin
      //     DummyFunction = in_val + 1;
      // endfunction
    endfunction

    generate
      if (FIXED_TAPS || (INITIAL_COEFFS != "")) begin : LOAD_COEFFS
         initial begin
             $readmemh(INITIAL_COEFFS, coef_mem_messy);
         end
      end else begin : DYNAMIC_COEFFS
         reg [LGNCOEF-1:0] tap_wr_idx;
         initial tap_wr_idx = 0;
         always @(posedge i_clk) begin
            if (i_reset)
                tap_wr_idx <= 0;
            else if (i_tap_wr)
                tap_wr_idx <= tap_wr_idx + 1'b1;
         end
         always @(posedge i_clk) begin
            if (i_tap_wr)
                coef_mem_messy[tap_wr_idx] <= i_tap;
         end
      end
    endgenerate

    // Initialization of control registers
    initial write_idx = 0;
    always @(posedge i_clk) begin
        if (i_ce)
            write_idx <= write_idx + 1;
    end

    // Data Memory Operations
    always @(posedge i_clk) begin
        if (i_ce) begin
            dmem1_messy[write_idx] <= i_sample;
            dmem2_messy[write_idx] <= mid_sample_messy;
        end
    end

    always @(posedge i_clk) begin
        if (i_reset)
            mid_sample_messy <= 0;
        else if (i_ce)
            mid_sample_messy <= sample_left;
    end

    // Compute Remaining Taps
    assign remaining_taps = NTAPS - tap_idx;
    assign last_tap_warn = (remaining_taps <= 1);
    assign last_data_warn = (remaining_taps <= 2);

    // Flag Update
    initial messy_flag = 4'b0;
    always @(posedge i_clk) begin
        if (i_reset)
            messy_flag[0] <= 1'b0;
        else if (i_ce)
            messy_flag[0] <= 1'b1;
        else if (messy_flag[0] && !last_tap_warn)
            messy always @(posedge i_clk) begin
                messy_flag[0] <= 1'b1;
            end
        else if (!clk_en)
            messy_flag[0] <= 1'b0;
    end

    // Control Enable Update
    always @(posedge i_clk) begin
        if (i_reset)
            messy_flag[3:1] <= 3'b0;
        else
            messy_flag[3:1] <= { messy_flag[2:1], (clk_en || (messy_flag[0] && !last_tap_warn)) };
    end

    // Index Update
    always @(posedge i_clk) begin
        if (i_reset) begin
            left_idx <= 0;
            right_idx <= 0;
        end else if (i_ce) begin
            left_idx <= write_idx;
            right_idx <= write_idx - (HALFTAPS[LGNMEM-1:0]) + 1;
        end else if (clk_en || !last_data_warn) begin
            left_idx <= left_idx - 2;
            right_idx <= right_idx + 2;
        end
    end

    // Tap Index Update
    always @(posedge i_clk) begin
        if (i_reset)
            tap_idx <= 0;
        else if (!last_tap_warn)
            tap_idx <= tap_idx + 1;
    end

    // Clock Enable
    initial clk_en = 1'b0;
    always @(posedge i_clk) begin
        clk_en <= (i_ce && !i_reset);
    end

    // Data Enable
    initial data_en = 1'b0;
    always @(posedge i_clk) begin
        data_en <= (clk_en && !i_reset);
    end

    // Coefficient Read and Data Sum Computation
    reg [TW-1:0] current_coef;
    initial current_coef = 0;
    always @(posedge i_clk) begin
        current_coef <= coef_mem_messy[tap_idx[LGNCOEF-1:0]];
    end

    initial sum_data = 0;
    always @(posedge i_clk) begin
        if (i_reset)
            sum_data <= 0;
        else if (OPT_HILBERT)
            sum_data <= sample_left - sample_right;
        else
            sum_data <= sample_left + sample_right;
    end

    // Summation Enable
    initial sum_en = 1'b0;
    always @(posedge i_clk) begin
        sum_en <= (data_en && !i_reset);
    end

    // Multiply Operation
    initial mult_result = 0;
    always @(posedge i_clk) begin
        mult_result <= current_coef * sum_data;
    end

    // Midpoint Generation
    always @(posedge i_clk) begin
        if (OPT_HILBERT) begin : NO_MIDPOINT
            mult_result <= 0;
        end else begin : GEN_MIDPOINT
            reg [OW-1:0] mid_prod_reg;
            initial mid_prod_reg = 0;
            always @(posedge i_clk) begin
                if (i_reset)
                    mid_prod_reg <= 0;
                else if (clk_en)
                    mid_prod_reg <= { {(OW-IW-TW+1){mid_sample_messy[IW-1]}}, 
                                  mid_sample_messy, {(TW-1){1'b0}} }
                              - { {(OW-IW){mid_sample_messy[IW-1]}}, 
                                  mid_sample_messy };
            end
            assign mult_result = mid_prod_reg;
        end
    end

    // Accumulation
    initial acc_result = 0;
    always @(posedge i_clk) begin
        if (i_reset)
            acc_result <= 0;
        else if (sum_en)
            acc_result <= mult_result;
        else if (messy_flag[3])
            acc_result <= acc_result + { {(OW-(IW+TW)){mult_result[IW+TW-1]}}, mult_result };
    end

    // Output Assignments
    initial o_result = 0;
    always @(posedge i_clk) begin
        if (sum_en)
            o_result <= acc_result;
    end

    // Output Clock Enable Update
    initial o_ce = 1'b0;
    always @(posedge i_clk) begin
        o_ce <= (sum_en && !i_reset);
    end

endmodule
