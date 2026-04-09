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

    // Internal signals
    logic [WIDTH-1:0] A_reg, B_reg, sum_reg; // Registers for A, B, and intermediate sum
    logic start, valid_out_reg; // Internal signals for computation stages

    // Reset block
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg <= 0;
            B_reg <= 0;
            sum_reg <= 0;
            start <= 0;
            valid_out_reg <= 0;
        end else begin
            A_reg <= A;
            B_reg <= B;
        end
    end

    // Computation, accumulation, and output stage
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            start <= 0;
            valid_out_reg <= 0;
        end else begin
            if (valid_in) begin
                start <= 1;
                valid_out_reg <= 0;
            end else if (start) begin
                sum_reg <= sum_reg + (B_reg << A_reg); // Add shifted value of B

                if (sum_reg[WIDTH-1:0] != sum_reg[WIDTH-2:1]) begin
                    sum_reg <= sum_reg + (B_reg << A_reg); // Continue accumulation
                end

                if (WIDTH == sum_reg[0]) begin
                    Product <= sum_reg; // Final accumulated product
                    valid_out_reg <= 1;
                    start <= 0;
                end
            end
        end
    end

    // Valid output signal
    assign valid_out = valid_out_reg;

endmodule
