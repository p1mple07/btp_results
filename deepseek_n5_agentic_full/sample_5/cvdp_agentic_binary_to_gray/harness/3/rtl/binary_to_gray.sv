module binary_to_gray
    parameter WIDTH = 8;
    reg [WIDTH-1:0] binary_in;
    wire [WIDTH-1:0] gray_out;

    integer i;
    gray_out[WIDTH-1] = binary_in[WIDTH-1];
    for (i = WIDTH-2; i >= 0; i--)$
        gray_out[i] = binary_in[i] ^ binary_in[i+1];
endmodule