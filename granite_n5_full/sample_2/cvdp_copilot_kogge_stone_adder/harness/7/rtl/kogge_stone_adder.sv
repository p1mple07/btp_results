module kogge_stone_adder(
    input logic signed [15:0] a, b;
    output logic signed [15:0] sum;
    
    assign sum = a + b;
    
endmodule