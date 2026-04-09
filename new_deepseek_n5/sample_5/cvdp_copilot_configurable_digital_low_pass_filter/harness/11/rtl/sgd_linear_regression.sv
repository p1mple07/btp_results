module sgd_linear_regression #(
    parameter DATA_WIDTH = 16, 
    parameter LEARNING_RATE = 3'd1
) (
    input  logic clk,                               // Clock
    input  logic reset,                             // Asynchronous reset
    input  logic signed [DATA_WIDTH-1:0] x_in,      // Input data (x)
    input  logic signed [DATA_WIDTH-1:0] y_true,    // True output (target)
    output logic signed [DATA_WIDTH-1:0] w,     // Trained weight
    output logic signed [DATA_WIDTH-1:0] b      // Trained bias
);
    localparam NBW_PRED  = 2*DATA_WIDTH + 1;
    localparam NBW_ERROR = NBW_PRED + 1;
    localparam NBW_DELTA = 3 + NBW_ERROR + DATA_WIDTH;

    // Intermediate values
    logic signed [NBW_PRED-1:0] y_pred;  
    logic signed [NBW_ERROR-1:0] error;  
    logic signed [NBW_DELTA-1:0] delta_w; 
    logic signed [NBW_DELTA-1:0] delta_b;

    // Predicted output caculation
    always_comb begin
        y_pred = (w * x_in) + b;
        error = y_true - y_pred;
        delta_w = LEARNING_RATE * error * x_in;
        delta_b = LEARNING_RATE * error;
        w = (signed [DATA_WIDTH-1:0]) (w + delta_w);
        b = (signed [DATA_WIDTH-1:0]) (b + delta_b);
    end
endmodule