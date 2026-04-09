module signed_comparator #(
    parameter integer DATA_WIDTH = 16,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_TOLERANCE = 0,
    parameter integer TOLERANCE = 0,
    parameter integer SHIFT_LEFT = 0
)(
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

localparam DATA_WIDTH = DATA_WIDTH;
localparam REGISTER_OUTPUT = REGISTER_OUTPUT;
localparam ENABLE_TOLERANCE = ENABLE_TOLERANCE;
localparam TOLERANCE = TOLERANCE;
localparam SHIFT_LEFT = SHIFT_LEFT;

wire shifted_a, shifted_b;
wire diff;

assign shifted_a = a << SHIFT_LEFT;
assign shifted_b = b << SHIFT_LEFT;
wire diff = shifted_a - shifted_b;

if (enable_tolerance) begin
    if (abs(diff) <= TOLERANCE) begin
        eq = 1;
    end else if (a > b) begin
        gt = 1;
        lt = 0;
    end else begin
        gt = 0;
        lt = 1;
    end
    eq = 1;
end

else begin
    if (bypass) begin
        eq = 1;
        gt = 0;
        lt = 0;
    end
    else begin
        if (a > b) begin
            gt = 1;
            lt = 0;
        end else if (a < b) begin
            gt = 0;
            lt = 1;
        end else begin
            gt = 0;
            lt = 0;
            eq = 1;
        end
    end
end

if (REGISTER_OUTPUT) begin
    always @(posedge clk) begin
        gt <= exp_gt;
        lt <= exp_lt;
        eq <= exp_eq;
    end
end

always @(posedge clk) begin
    if (!enable) begin
        gt <= 0;
        lt <= 0;
        eq <= 0;
    end
end

endmodule
