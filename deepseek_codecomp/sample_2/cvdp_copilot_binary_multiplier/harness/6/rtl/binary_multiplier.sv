module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product     // Output Product
);

integer i;
logic [2*WIDTH-1:0] partial_products [WIDTH-1:0];  // Unsigned partial products
logic [2*WIDTH-1:0] sum;                           // Intermediate sum for unsigned mode

always @(*) begin
    // Initialize sum and partial products to zero
    sum = 0;
    for (i = 0; i < WIDTH; i = i + 1) begin
        partial_products[i] = 0;
    end

    if (valid_in) begin
        // Generate partial products
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (A[i]) begin
                partial_products[i] = B << i;  // Logical shift left for unsigned multiplication
            end
        end
        
        // Sum the partial products
        for (i = 0; i < WIDTH; i = i + 1) begin
            sum = sum + partial_products[i];
        end

        Product   = sum;    // Assign final product
    end else begin
        Product   = 0;
    end
end

endmodule