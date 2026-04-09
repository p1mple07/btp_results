module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic clk,          // Clock signal for synchronization
    input  logic rst_n,        // Active-low asynchronous reset
    input  logic valid_in,     // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A, // Input A
    input  logic [WIDTH-1:0] B, // Input B
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic valid_out         // Output valid
);

integer i;
logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication
logic [WIDTH-1:0] start;   // Control signal for sequential operation

// Internal registers
logic [WIDTH-1:0] A_reg, B_reg;
logic [2*WIDTH-1:0] Product_reg;

always_ff @(posedge clk) begin
    if (rst_n) begin
        sum <= 0;
        start <= 0;
        A_reg <= 0;
        B_reg <= 0;
        Product_reg <= 0;
    end else begin
        // Latch inputs on valid_in asserted
        if (valid_in) begin
            A_reg <= A;
            B_reg <= B;
            start <= 1;
        end

        // Sequential computation over WIDTH + 2 cycles
        for (i = 0; i < WIDTH + 2; i = i + 1) begin
            if (start) begin
                if (i < WIDTH) begin
                    if (A_reg[i]) begin
                        sum <= sum + (B_reg << i);  // Add shifted value of B
                    end
                end
            end

            // Register results on WIDTH + 2 cycle
            if (i == WIDTH + 1) begin
                Product_reg <= sum;
                start <= 0;
            end
        end
    end
end

always_comb begin
    Product <= Product_reg;
    valid_out <= start;
end

endmodule
