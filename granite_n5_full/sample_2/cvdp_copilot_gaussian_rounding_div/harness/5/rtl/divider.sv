module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    localparam logic [17:0] TWO  = 18'b000000010_000000000;
    localparam logic [17:0] ZERO = 18'b000000000_000000000;

    logic [17:0] D_0, N_0;
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [17:0] F, F1, F2, F3, F4, F5, F6, F7, F8, F9;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    always_comb begin : PRESCALING
        // Insert code here for 10 stage Gold-Schmidt division algorithm.
    end

endmodule


module pre_scaler (
    input  logic [17:0] a,  // unsigned divisor
    input  logic [17:0] c,  // unsigned dividend
    output logic [17:0] b,  // prescaled divisor
    output logic [17:0] d   // prescaled dividend
);

    always_comb begin : SHIFT_LOGIC
        // Insert Code here for scaling the inputs such that input a is <1.
    end

endmodule


module dff1 (
    input  logic clk,
    input  logic reset,
    input  logic d,
    output logic q
);
    // Insert code here for 1 bit parallel load register using D Flip Flops
endmodule


module reg18 (
    input  logic        clk,
    input  logic        reset,
    input  logic [17:0] data_in,
    output logic [17:0] data_out
);
    // Insert code here for 18 bit parallel load register using D Flip Flops
endmodule