module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    reg18 prescaler;
    reg18 main;

    // Prescaling logic
    prescaler #(.A(dividend), .C(divisor), .B(2)) (prescaler_out);

    // Main division logic
    main #(.DIVIDEND(dividend), .DIVISOR(divisor), .START(start)) (main_out);

endmodule

module prescaler (
    input  logic [17:0] a,  // dividend
    input  logic [17:0] b,  // divisor
    output logic [17:0] c,  // output
    output logic [17:0] d   // output
);
    // Prescaling: shift dividend by 8 to get integer part, shift divisor by 8 to get integer part.
    // But we only need to produce two outputs.
    assign c = a >> 8;
    assign d = b >> 8;
endmodule

module main (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // from prescaler
    input  logic         divisor,   // from prescaler
    output logic [17:0]  dv_out,
    output logic         valid
);

    reg18 div_logic;

    div_logic #(.DIVIDEND(dividend), .DIVISOR(divisor), .START(start)) (dv_out, valid);

endmodule
