module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic clk,         // Clock signal for synchronization
    input  logic rst_n,        // Active-low asynchronous reset
    input  logic valid_in,     // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A, // Input A
    input  logic [WIDTH-1:0] B, // Input B
    output logic [2*WIDTH-1:0] Product, // Output Product
    output logic valid_out    // Output valid
);

    integer i;
    logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication
    logic start = 1'b0;        // Start signal for sequential operation

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Product <= 0;
            valid_out <= 1'b0;
            start <= 1'b0;
        end else begin
            if (valid_in) begin
                start <= 1'b1;
                A <= A;
                B <= B;
            end else begin
                Product <= 0;
                valid_out <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (start) begin
            for (i = 0; i < WIDTH; i = i + 1) begin
                if (A[i]) begin
                    sum = sum + (B << i);  // Add shifted value of B
                end
            end
        end

        if (WIDTH + 2 == $time % (WIDTH + 2)) begin
            Product <= sum;  // Assign the final sum as the product
            valid_out <= 1'b1;
        end
    end

endmodule
