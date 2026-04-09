module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic               valid_out   // Output valid
);

reg start;
reg [WIDTH-1:0] sum;

initial begin
    start <= 1'b0;
end

always @(posedge clk) begin
    if (rst_n) begin
        start <= 1'b0;
        product <= 0;
        valid_output <= 1'b0;
    end else begin
        start <= 1'b1;
        for (int i = 0; i < WIDTH; i = i + 1) begin
            if (A[i]) begin
                sum = sum + B << i;  // Shift B left by i bits
            end
        end

        product = sum; 
        valid_output = 1'b1;
    end
end

endmodule
