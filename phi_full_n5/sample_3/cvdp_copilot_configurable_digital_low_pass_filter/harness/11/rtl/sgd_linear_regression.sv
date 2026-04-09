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

    // Predicted output calculation
    always_comb begin
      y_pred = (w * x_in) + b;
    end

    // Error calculation
    always_comb begin
      error = y_true - y_pred;
    end

    // Weight and bias updates
    always_comb begin
      delta_w = LEARNING_RATE * error * x_in;
      delta_b = LEARNING_RATE * error;
    end

    // Registers update
    always_ff begin
      if (reset) begin
        w <= {DATA_WIDTH{1'b0}};
        b <= {DATA_WIDTH{1'b0}};
      end else begin
        w <= w + delta_w;
        b <= b + delta_b;
      end
    end

endmodule
