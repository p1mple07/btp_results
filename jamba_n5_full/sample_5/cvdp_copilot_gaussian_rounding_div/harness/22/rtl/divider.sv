module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    // Define two registers
    reg18 current;
    reg18 result;

    // ... pipeline stages ...

endmodule
