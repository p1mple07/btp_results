module binary_multiplier #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    input  logic               valid_in,
    input  logic               rst_n,
    output logic [2*WIDTH-1:0] Product,
    output logic               valid_out
);

reg start = 0;
reg [WIDTH-1:0] a_reg = 0;
reg [WIDTH-1:0] b_reg = 0;
reg sum = 0;
integer i = 0;

always @posedge valid_in or posedge rst_n begin
    if (rst_n) begin
        sum = 0;
        a_reg = 0;
        b_reg = 0;
        start = 0;
    else
        start = 1;
    end
end

always @posedge clock begin
    if (start) begin
        if (i < WIDTH) begin
            if (a_reg[i]) begin
                sum = sum + (b_reg << i);
            end
            i = i + 1;
        end
    end
end

if (i == WIDTH) begin
    Product = sum;
    valid_out = 1;
end
endmodule