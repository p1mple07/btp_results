module kogge_stone_adder(
    input logic [31:0] A,
    input logic [31:0] B,
    output logic [31:0] Sum
);

assign Sum = A+B;

endmodule