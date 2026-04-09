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

localparam integer SHIFT = SHIFT_LEFT;
localparam integer TOL = TOLERANCE;

reg [DATA_WIDTH-1:0] a_shift, b_shift;
reg diff_abs;
reg enable_comp;

always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        a_shift <= 0;
        b_shift <= 0;
        diff_abs <= 0;
        gt <= 0;
        lt <= 0;
        eq <= 0;
    end else begin
        a_shift = a << SHIFT;
        b_shift = b << SHIFT;
        diff_abs = a_shift - b_shift;
        enable_comp = enable;
    end
end

always @(*) begin
    if (enable_comp) begin
        if (enable) begin
            if (bypass) begin
                eq = 1;
                gt = 0;
                lt = 0;
            end else begin
                if (a_shift > b_shift) begin
                    gt = 1;
                    lt = 0;
                    eq = 0;
                end else if (a_shift < b_shift) begin
                    gt = 0;
                    lt = 1;
                    eq = 0;
                end else begin
                    gt = 0;
                    lt = 0;
                    eq = 1;
                end
            end
        end else begin
            gt = 0;
            lt = 0;
            eq = 0;
        end
    end
end

endmodule
