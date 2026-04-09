module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    reg18 dividend_in;
    reg18 divisor_in;

    // ... rest of the code using these two registers ...

endmodule
