module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic               valid_out   // Output valid
);

integer i;
logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 0;
        valid_out <= 1'b0;
    end else if (valid_in) begin
        sum <= 0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (A[i]) begin
                sum <= sum + (B << i);  // Add shifted value of B
            end
        end
      
        Product <= sum;
        valid_out <= 1'b1;
    end
end

endmodule