module sgd_linear_regression #(
    parameter DATA_WIDTH = 16, 
    parameter LEARNING_RATE = 3'd1
) (
    input  logic clk,                               
    input  logic reset,                             
    input  logic signed [DATA_WIDTH-1:0] x_in,      
    input  logic signed [DATA_WIDTH-1:0] y_true,    
    output logic signed [DATA_WIDTH-1:0] w,      
    output logic signed [DATA_WIDTH-1:0] b       
);
    localparam NBW_PRED  = 2*DATA_WIDTH + 1;
    localparam NBW_ERROR = NBW_PRED + 1;
    localparam NBW_DELTA = 3 + NBW_ERROR + DATA_WIDTH;

    // Intermediate values
    logic signed [NBW_PRED-1:0] y_pred;  
    logic signed [NBW_ERROR-1:0] error;  
    logic signed [NBW_DELTA-1:0] delta_w; 
    logic signed [NBW_DELTA-1:0] delta_b;

    // Predicted output calculation
    always_comb begin
      y_pred = (w * x_in) + b;
    end

    // Error calculation: error = y_true - y_pred
    always_comb begin
      error = y_true - y_pred;
    end

    // Weight and bias updates
    // delta_w = LEARNING_RATE * error * x_in
    // delta_b = LEARNING_RATE * error
    always_comb begin
      delta_w = LEARNING_RATE * error * x_in;
      delta_b = LEARNING_RATE * error;
    end

    // Update registers w and b on each clock cycle if reset is not active.
    // Only the lower DATA_WIDTH bits are kept.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            w <= '0;
            b <= '0;
        end else begin
            w <= w + delta_w[DATA_WIDTH-1:0];
            b <= b + delta_b[DATA_WIDTH-1:0];
        end
    end

endmodule