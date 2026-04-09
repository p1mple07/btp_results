module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic               valid_out   // Output valid
);

// Internal signals and variables
logic start;
logic [WIDTH-1:0] acc_sum;
logic [WIDTH-1:0] reg_a;
logic [WIDTH-1:0] reg_b;

// Sequential process
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start <= 1'b0;
        acc_sum <= 0;
        reg_a <= 0;
        reg_b <= 0;
    end else begin
        // Start the multiplication operation based on valid_in
        if (valid_in &&!start) begin
            start <= 1'b1;
            reg_a <= A;
            reg_b <= B;
        end

        // Shift and accumulate the multiplication results
        if (start) begin
            for (int i = 0; i < WIDTH; i = i + 1) begin
                if (reg_a[i]) begin
                    acc_sum <= acc_sum + (reg_b << i);
                end
            end

            // Check if all bits in A are processed
            if (i == WIDTH) begin
                Product <= acc_sum;
                valid_out <= 1'b1;
                start <= 1'b0;
            end
        end
    end
end

endmodule