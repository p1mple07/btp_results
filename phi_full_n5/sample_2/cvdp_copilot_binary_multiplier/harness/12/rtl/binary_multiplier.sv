module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic clk,           // Clock signal for synchronization
    input  logic rst_n,         // Active-low asynchronous reset
    input  logic valid_in,      // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,  // Input A
    input  logic [WIDTH-1:0] B,  // Input B
    output logic valid_out,     // Output valid
    output logic [2*WIDTH-1:0] Product  // Output Product
);

    integer i;
    logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication
    logic start;              // Control signal for sequential operation

    always_ff @(posedge clk) begin
        if (rst_n) begin
            sum <= 0;
            start <= 0;
            Product <= 0;
            valid_out <= 0;
        end else begin
            if (valid_in) begin
                start <= 1;
                A <= A;
                B <= B;
            end else begin
                start <= 0;
            end
            
            if (start) begin
                for (i = 0; i < WIDTH; i = i + 1) begin
                    if (A[i]) begin
                        sum = (sum << i) + B;  // Shift and add B
                    end
                end
                
                if (i == WIDTH - 1) begin
                    Product <= sum;  // Final Product after WIDTH cycles
                    valid_out <= 1'b1;
                end
            end
        end
    end

endmodule
