////////////////////////////////////////////////
// Top-Level Gold-Schmidt Division Module
////////////////////////////////////////////////
module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    //////////////////////////////////////////////
    // Local parameters
    //////////////////////////////////////////////
    localparam logic [17:0] TWO  = 18'b000000010_000000000;
    localparam logic [17:0] ZERO = 18'b000000000_000000000;

    //////////////////////////////////////////////
    // Internal signals
    //////////////////////////////////////////////
    logic [17:0] D_0, N_0;
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [17:0] F, F1, F2, F3, F4, F5, F6, F7, F8, F9;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    // Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Gold-Schmidt Division algorithm
    always @(posedge clk) begin
        if (rst_n) begin
            D_0 <= ZERO;
            N_0 <= ZERO;
            D <= divisor;
            N <= dividend;
            F <= TWO;
            st1 <= 1'b0;
        end else if (start) begin
            D_0 <= D;
            N_0 <= N;
            F <= F1;
            st1 <= 1'b1;
        end else begin
            st1 <= st1;
            if (st1) begin
                D <= D * F;
                N <= N * F;
                F <= F2;
                st2 <= st2;
            end else begin
                D <= D2;
                N <= N2;
                F <= F3;
                st2 <= st2;
            end
            // Repeat the above block for st3 to st10
            // ...
            // Final stage
            if (st10) begin
                D <= D18;
                N <= N21;
                dv_out <= N;
                valid <= 1'b1;
            end
        end
    end

endmodule


////////////////////////////////////////////////
// Pre-scaling (Prescaling) Module
////////////////////////////////////////////////
module pre_scaler (
    input  logic [17:0] a,  // unsigned divisor
    input  logic [17:0] c,  // unsigned dividend
    output logic [17:0] b,  // prescaled divisor
    output logic [17:0] d   // prescaled dividend
);

    always_comb begin : SHIFT_LOGIC
        // Prescale the inputs to ensure 0 < D < 1
        b <= a >> 9;
        d <= c >> 9;
    end

endmodule


////////////////////////////////////////////////
// Single-bit DFF
////////////////////////////////////////////////
module dff1 (
    input  logic clk,
    input  logic reset,
    input  logic d,
    output logic q
);
    assign q = (reset) ? 0 : d;
endmodule


////////////////////////////////////////////////
// 18-bit register (parallel load)
////////////////////////////////////////////////
module reg18 (
    input  logic        clk,
    input  logic        reset,
    input  logic [17:0] data_in,
    output logic [17:0] data_out
);
    reg [17:0] data_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out_reg <= 18'b0;
        end else begin
            data_out_reg <= data_in;
        end
    end

    assign data_out = data_out_reg;
endmodule
