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

    logic signed [NBW_PRED-1:0] y_pred;
    logic signed [NBW_ERROR-1:0] error;
    logic signed [NBW_DELTA-1:0] delta_w;
    logic signed [NBW_DELTA-1:0] delta_b;

    always @(posedge clk or posedge reset) begin
      if (reset) begin
        w <= 0;
        b <= 0;
      end else
      begin
        y_pred = w * x_in + b;
        error = y_true - y_pred;
        delta_w = LEARNING_RATE * error * x_in;
        delta_b = LEARNING_RATE * error;
        w = w + delta_w;
        b = b + delta_b;
      end
    end

endmodule
