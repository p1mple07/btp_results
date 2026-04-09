module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic clk,       // Clock signal for synchronization
    input  logic rst_n,     // Active-low asynchronous reset
    input  logic valid_in,  // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,         // Input A
    input  logic [WIDTH-1:0] B,         // Input B
    output logic [2*WIDTH-1:0] Product,  // Output Product
    output logic valid_out  // Output valid
);

// Internal signals
logic start, done;
logic [WIDTH-1:0] a_reg, b_reg;
logic [2*WIDTH-1:0] acc;

// Computation, accumulation, and output stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start <= 1'b0;
        a_reg <= 0;
        b_reg <= 0;
        acc <= 0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            start <= 1'b1;
            a_reg <= A;
            b_reg <= B;
            acc <= 0;
        end
        
        if (start) begin
            for (int i=0; i<WIDTH; i++) begin
                if (a_reg[i]) begin
                    acc <= {acc[WIDTH+1:2], B[i]};
                end
            end
            
            if ((WIDTH+1) == $clog2(WIDTH)+1) begin
                Product <= acc;
                done <= 1'b1;
            end else begin
                acc <= {acc[WIDTH+1:2], 1'b0};
            end
            
            if (done) begin
                valid_out <= 1'b1;
            end
        end
    end
end

// Valid signal behavior
assign valid_out = done;

endmodule