module signed_comparator #(
    parameter integer DATA_WIDTH = 16,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_TOLERANCE = 0,
    parameter integer TOLERANCE = 0,
    parameter integer SHIFT_LEFT = 0
) (
    input  wire clk,
    input  wire rst_n,
    input  wire enable,
    input  wire bypass,
    input  wire signed [DATA_WIDTH-1:0] a,
    input  wire signed [DATA_WIDTH-1:0] b,
    output reg gt,
    output reg lt,
    output reg eq
);

    localparam integer DATA_WIDTH = DATA_WIDTH;
    localparam integer REGISTER_OUTPUT = REGISTER_OUTPUT;
    localparam integer ENABLE_TOLERANCE = ENABLE_TOLERANCE;
    localparam integer TOLERANCE = TOLERANCE;
    localparam integer SHIFT_LEFT = SHIFT_LEFT;

    reg clk;
    reg rst_n;
    reg enable;
    reg bypass;
    reg signed [15:0] a_shift, b_shift;
    reg signed [DATA_WIDTH:0] diff_abs;
    reg exp_gt, exp_lt, exp_eq;

    // Always block for initial simulation, but we use @(posedge clk)
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            a_shift <= 0;
            b_shift <= 0;
            diff_abs <= 0;
            exp_gt <= 0;
            exp_lt <= 0;
            exp_eq <= 0;
        end else begin
            a_shift = a << SHIFT_LEFT;
            b_shift = b << SHIFT_LEFT;
            diff_abs = a_shift - b_shift;
            exp_gt = (a_shift > b_shift);
            exp_lt = (a_shift < b_shift);
            exp_eq = (a_shift == b_shift);
        end
    end

    assign gt = (bypass) ? 1 : (exp_gt && exp_lt) ? 0 : ((a_shift > b_shift) ? 1 : 0);
    assign lt = (bypass) ? 0 : (exp_lt && exp_gt) ? 0 : ((a_shift < b_shift) ? 1 : 0);
    assign eq = (bypass) ? 1 : ((a_shift == b_shift) ? 1 : 0);

endmodule
