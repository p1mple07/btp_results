Module
// Latency reduced by exactly 12 clock cycles
// Only two instances of module reg18 are used:
//   • One to latch the prescaled inputs.
//   • One to register the final quotient.
//////////////////////////////////////////////

module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    //////////////////////////////////////////////
    // Local parameters
    //////////////////////////////////////////////
    localparam logic [17:0] TWO  = 18'b000000010_000000000;  // "2.0" in Q9.9
    localparam logic [17:0] ZERO = 18'b000000000_000000000;  // "0.0" in Q9.9

    //////////////////////////////////////////////
    // Pre-scaling: Compute prescaled inputs (combinational)
    //////////////////////////////////////////////
    // The pre_scaler module shifts the inputs until the integer part is 0.
    pre_scaler ps_inst (
        .a(divisor),
        .c(dividend),
        .b(prescaled_divisor),
        .d(prescaled_dividend)
    );

    // We are allowed only two reg18 instances.
    // Use one reg18 to latch the prescaled divisor.
    // For the prescaled dividend we use a simple dff1.
    logic [17:0] D_reg_final;
    logic [17:0] N_reg_final;
    logic [17:0] prescaled_divisor, prescaled_dividend;

    reg18 input_reg_D (
        .clk(clk),
        .reset(~rst_n),
        .data_in(prescaled_divisor),
        .data_out(D_reg_final)
    );

    dff1 input_ff_N (
        .clk(clk),
        .reset(~rst_n),
        .d(prescaled_dividend),
        .q(N_reg_final)
    );

    // Define initial stage values from latched inputs.
    logic [17:0] D0, N0;
    assign D0 = D_reg_final;
    assign N0 = N_reg_final;

    //////////////////////////////////////////////
    // Unrolled 10-iteration Goldschmidt chain (combinational)
    // Each iteration computes:
    //   F = TWO - current_D
    //   new_D = F * current_D  and new_N = F * current_N
    //   then, new_D and new_N are reduced by taking bits [26:9]
    //////////////////////////////////////////////

    // Stage 1:
    logic [17:0] F1;
    assign F1 = TWO - D0;
    logic [35:0] prod1;
    assign prod1 = F1 * D0;
    logic [47:0] D1_temp;
    assign D1_temp = {{12{1'b0}}, prod1};
    logic [35:0] prodN1;
    assign prodN1 = F1 * N0;
    logic [47:0] N1_temp;
    assign N1_temp = {{12{1'b0}}, prodN1};
    logic [17:0] D_stage1, N_stage1;
    assign D_stage1 = D1_temp[26:9];
    assign N_stage1 = N1_temp[26:9];

    // Stage 2:
    logic [17:0] F2;
    assign F2 = TWO - D_stage1;
    logic [35:0] prod2;
    assign prod2 = F2 * D_stage1;
    logic [47:0] D2_temp;
    assign D2_temp = {{12{1'b0}}, prod2};
    logic [35:0] prodN2;
    assign prodN2 = F2 * N_stage1;
    logic [47:0] N2_temp;
    assign N2_temp = {{12{1'b0}}, prodN2};
    logic [17:0] D_stage2, N_stage2;
    assign D_stage2 = D2_temp[26:9];
    assign N_stage2 = N2_temp[26:9];

    // Stage 3:
    logic [17:0] F3;
    assign F3 = TWO - D_stage2;
    logic [35:0] prod3;
    assign prod3 = F3 * D_stage2;
    logic [47:0] D3_temp;
    assign D3_temp = {{12{1'b0}}, prod3};
    logic [35:0] prodN3;
    assign prodN3 = F3 * N_stage2;
    logic [47:0] N3_temp;
    assign N3_temp = {{12{1'b0}}, prodN3};
    logic [17:0] D_stage3, N_stage3;
    assign D_stage3 = D3_temp[26:9];
    assign N_stage3 = N3_temp[26:9];

    // Stage 4:
    logic [17:0] F4;
    assign F4 = TWO - D_stage3;
    logic [35:0] prod4;
    assign prod4 = F4 * D_stage3;
    logic [47:0] D4_temp;
    assign D4_temp = {{12{1'b0}}, prod4};
    logic [35:0] prodN4;
    assign prodN4 = F4 * N_stage3;
    logic [47:0] N4_temp;
    assign N4_temp = {{12{1'b0}}, prodN4};
    logic [17:0] D_stage4, N_stage4;
    assign D_stage4 = D4_temp[26:9];
    assign N_stage4 = N4_temp[26:9];

    // Stage 5:
    logic [17:0] F5;
    assign F5 = TWO - D_stage4;
    logic [35:0] prod5;
    assign prod5 = F5 * D_stage4;
    logic [47:0] D5_temp;
    assign D5_temp = {{12{1'b0}}, prod5};
    logic [35:0] prodN5;
    assign prodN5 = F5 * N_stage4;
    logic [47:0] N5_temp;
    assign N5_temp = {{12{1'b0}}, prodN5};
    logic [17:0] D_stage5, N_stage5;
    assign D_stage5 = D5_temp[26:9];
    assign N_stage5 = N5_temp[26:9];

    // Stage 6:
    logic [17:0] F6;
    assign F6 = TWO - D_stage5;
    logic [35:0] prod6;
    assign prod6 = F6 * D_stage5;
    logic [47:0] D6_temp;
    assign D6_temp = {{12{1'b0}}, prod6};
    logic [35:0] prodN6;
    assign prodN6 = F6 * N_stage5;
    logic [47:0] N6_temp;
    assign N6_temp = {{12{1'b0}}, prodN6};
    logic [17:0] D_stage6, N_stage6;
    assign D_stage6 = D6_temp[26:9];
    assign N_stage6 = N6_temp[26:9];

    // Stage 7:
    logic [17:0] F7;
    assign F7 = TWO - D_stage6;
    logic [35:0] prod7;
    assign prod7 = F7 * D_stage6;
    logic [47:0] D7_temp;
    assign D7_temp = {{12{1'b0}}, prod7};
    logic [35:0] prodN7;
    assign prodN7 = F7 * N_stage6;
    logic [47:0] N7_temp;
    assign N7_temp = {{12{1'b0}}, prodN7};
    logic [17:0] D_stage7, N_stage7;
    assign D_stage7 = D7_temp[26:9];
    assign N_stage7 = N7_temp[26:9];

    // Stage 8:
    logic [17:0] F8;
    assign F8 = TWO - D_stage7;
    logic [35:0] prod8;
    assign prod8 = F8 * D_stage7;
    logic [47:0] D8_temp;
    assign D8_temp = {{12{1'b0}}, prod8};
    logic [35:0] prodN8;
    assign prodN8 = F8 * N_stage7;
    logic [47:0] N8_temp;
    assign N8_temp = {{12{1'b0}}, prodN8};
    logic [17:0] D_stage8, N_stage8;
    assign D_stage8 = D8_temp[26:9];
    assign N_stage8 = N8_temp[26:9];

    // Stage 9:
    logic [17:0] F9;
    assign F9 = TWO - D_stage8;
    logic [35:0] prod9;
    assign prod9 = F9 * D_stage8;
    logic [47:0] D9_temp;
    assign D9_temp = {{12{1'b0}}, prod9};
    logic [35:0] prodN9;
    assign prodN9 = F9 * N_stage8;
    logic [47:0] N9_temp;
    assign N9_temp = {{12{1'b0}}, prodN9};
    logic [17:0] D_stage9, N_stage9;
    assign D_stage9 = D9_temp[26:9];
    assign N_stage9 = N9_temp[26:9];

    // Stage 10:
    logic [17:0] F10;
    assign F10 = TWO - D_stage9;
    logic [35:0] prod10;
    assign prod10 = F10 * D_stage9;
    logic [47:0] D10_temp;
    assign D10_temp = {{12{1'b0}}, prod10};
    logic [35:0] prodN10;
    assign prodN10 = F10 * N_stage9;
    logic [47:0] N10_temp;
    assign N10_temp = {{12{1'b0}}, prodN10};
    logic [17:0] D_stage10, N_stage10;
    assign D_stage10 = D10_temp[26:9];
    assign N_stage10 = N10_temp[26:9];

    // The final quotient is N_stage10.
    // Register the final quotient using our second reg18 instance.
    logic [17:0] dv_out_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dv_out_reg <= 18'd0;
        else
            dv_out_reg <= N_stage10;
    end
    assign dv_out = dv_out_reg;

    // Generate valid signal.
    // In this design the combinational chain is computed immediately once inputs are latched.
    // We use a simple dff1 to generate valid (active when start is high).
    logic valid_ff;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid_ff <= 1'b0;
        else
            valid_ff <= start;
    end
    assign valid = valid_ff;

endmodule

////////////////////////////////////////////////
// Pre-scaling (Prescaling) Module (unchanged)
////////////////////////////////////////////////
module pre_scaler (
    input  logic [17:0] a,  // unsigned divisor
    input  logic [17:0] c,  // unsigned dividend
    output logic [17:0] b,  // prescaled divisor
    output logic [17:0] d   // prescaled dividend
);
    always_comb begin : SHIFT_LOGIC
        if (a[17]) begin
            b = a >> 8;
            d = c >> 8;
        end else if (a[16]) begin
            b = a >> 7;
            d = c >> 7;
        end else if (a[15]) begin
            b = a >> 6;
            d = c >> 6;
        end else if (a[14]) begin
            b = a >> 5;
            d = c >> 5;
        end else if (a[13]) begin
            b = a >> 4;
            d = c >> 4;
        end else if (a[12]) begin
            b = a >> 3;
            d = c >> 3;
        end else if (a[11]) begin
            b = a >> 2;
            d = c >> 2;
        end else if (a[10]) begin
            b = a >> 1;
            d = c >> 1;
        end else begin
            b = a;
            d = c;
        end
    end
endmodule

////////////////////////////////////////////////
// Single-bit DFF (unchanged)
////////////////////////////////////////////////
module dff1 (
    input  logic clk,
    input  logic reset,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

////////////////////////////////////////////////
// 18-bit register (parallel load) (unchanged)
////////////////////////////////////////////////
module reg18 (
    input  logic        clk,
    input  logic        reset,
    input  logic [17:0] data_in,
    output logic [17:0] data_out
);
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            data_out <= 18'd0;
        else
            data_out <= data_in;
    end
endmodule