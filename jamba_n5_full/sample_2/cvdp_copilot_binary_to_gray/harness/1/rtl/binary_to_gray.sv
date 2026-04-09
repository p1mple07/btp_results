module binary_to_gray (
    input  wire [WIDTH-1:0] binary_in, 
    output wire [WIDTH-1:0] gray_out
);

reg [WIDTH-1:0] temp;

always @(*) begin
    gray_out = binary_in;
    for (int i = WIDTH-2; i >= 0; i=i-1) begin
        gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
end

endmodule
