module iir_filter (
    input  logic clk,
    input  logic rst,
    input  logic signed [15:0] x,    
    output logic signed [15:0] y    
);

    // Filter coefficients
    parameter signed [15:0] b0 = 16'h0F00;
    parameter signed [15:0] b1 = 16'h0E00;
    parameter signed [15:0] b2 = 16'h0D00;
    parameter signed [15:0] b3 = 16'h0C00;
    parameter signed [15:0] b4 = 16'h0B00;
    parameter signed [15:0] b5 = 16'h0A00;
    parameter signed [15:0] b6 = 16'h0900;
    parameter signed [15:0] a1 = -16'h0800;
    parameter signed [15:0] a2 = -16'h0700;
    parameter signed [15:0] a3 = -16'h0600;
    parameter signed [15:0] a4 = -16'h0500;
    parameter signed [15:0] a5 = -16'h0400;
    parameter signed [15:0] a6 = -16'h0300;

    // Internal registers for previous inputs and outputs
    logic signed [15:0] x_prev1, x_prev2, x_prev3, x_prev4, x_prev5, x_prev6;
    logic signed [15:0] y_prev1, y_prev2, y_prev3, y_prev4, y_prev5, y_prev6;
    
    // Intermediate accumulator (32-bit for multiplication results)
    logic signed [31:0] temp_y;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            x_prev1 <= 0; x_prev2 <= 0; x_prev3 <= 0;
            x_prev4 <= 0; x_prev5 <= 0; x_prev6 <= 0;
            y_prev1 <= 0; y_prev2 <= 0; y_prev3 <= 0;
            y_prev4 <= 0; y_prev5 <= 0; y_prev6 <= 0;
        end else begin
            // Compute the filter output using past inputs and outputs.
            // Use arithmetic shift (>>) since temp_y is signed.
            temp_y = (b0 * x + b1 * x_prev1 + b2 * x_prev2 + b3 * x_prev3 +
                      b4 * x_prev4 + b5 * x_prev5 + b6 * x_prev6 -
                      a1 * y_prev1 - a2 * y_prev2 - a3 * y_prev3 -
                      a4 * y_prev4 - a5 * y_prev5 - a6 * y_prev6) >> 16;

            // Drive y based on condition in a single assignment to avoid multiple drivers.
            y <= (x > 16'h8000) ? 16'h7FFF : temp_y;

            // Update shift registers for inputs and outputs.
            x_prev6 <= x_prev5; 
            x_prev5 <= x_prev4; 
            x_prev4 <= x_prev3; 
            x_prev3 <= x_prev2; 
            x_prev2 <= x_prev1; 
            x_prev1 <= x;
            
            y_prev6 <= y_prev5; 
            y_prev5 <= y_prev4; 
            y_prev4 <= y_prev3; 
            y_prev3 <= y_prev2; 
            y_prev2 <= y_prev1; 
            y_prev1 <= y;
        end
    end

endmodule