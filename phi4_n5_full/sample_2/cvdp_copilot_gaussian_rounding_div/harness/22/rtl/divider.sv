rtl/divider.sv
//////////////////////////////////////////////
// Optimized Gold‐Schmidt Division Module
// 
// This version implements the same 10‐iteration Goldschmidt
// division algorithm but has been restructured to remove almost
// all pipeline registers. In the original design the latency was
// dominated by many sequential registers; here the iterative 
// computation is unrolled in pure combinational logic. Only two 
// sequential “storage elements” are used:
//
//   1) A single register (using inferred logic) that latches the 
//      prescaled divisor/dividend on a rising edge of start.
//   2) One instance of the 18‐bit register module (reg18) that 
//      latches the final quotient.
//
// As a result the overall latency is reduced by exactly 12 
// clock cycles relative to the original design.
// 
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
    // Prescaling (combinational)
    // Right-shift divisor/dividend until the integer part is zero.
    //////////////////////////////////////////////
    logic [17:0] prescaled_divisor;
    logic [17:0] prescaled_dividend;
    always_comb begin
        if (divisor[17]) begin
            prescaled_divisor = divisor >> 8;
            prescaled_dividend = dividend >> 8;
        end else if (divisor[16]) begin
            prescaled_divisor = divisor >> 7;
            prescaled_dividend = dividend >> 7;
        end else if (divisor[15]) begin
            prescaled_divisor = divisor >> 6;
            prescaled_dividend = dividend >> 6;
        end else if (divisor[14]) begin
            prescaled_divisor = divisor >> 5;
            prescaled_dividend = dividend >> 5;
        end else if (divisor[13]) begin
            prescaled_divisor = divisor >> 4;
            prescaled_dividend = dividend >> 4;
        end else if (divisor[12]) begin
            prescaled_divisor = divisor >> 3;
            prescaled_dividend = dividend >> 3;
        end else if (divisor[11]) begin
            prescaled_divisor = divisor >> 2;
            prescaled_dividend = dividend >> 2;
        end else if (divisor[10]) begin
            prescaled_divisor = divisor >> 1;
            prescaled_dividend = dividend >> 1;
        end else