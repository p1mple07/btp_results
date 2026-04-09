module gf_multiplier (
    input logic signed [7:0] A, 
    input logic signed [7:0] B,
    output logic signed [7:0] result
);
    
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] result;
    
always @(posedge clk) begin
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] result;
    
    //...

endmodule