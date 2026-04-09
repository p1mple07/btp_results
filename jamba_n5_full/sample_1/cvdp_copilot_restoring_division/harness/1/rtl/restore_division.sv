module restoring_division #(
    parameter WIDTH = 6
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output wire valid
);

reg [WIDTH-1:0] temp_remainder;
reg [WIDTH-1:0] q;
reg [WIDTH-1:0] r;

always @(posedge clk or posedge rst) begin
    if (!rst) begin
        quotient <= 0;
        remainder <= 0;
        valid <= 0;
    end else if (start) begin
        quotient <= 0;
        remainder <= 0;
        valid <= 0;
        temp_remainder <= 0;
        q <= 0;
        r <= 0;
    end else begin
        valid <= 0;
    end
end

always_ff @(posedge clk) begin
    if (valid) begin
        // shift remainder left, append dividend bit
        temp_remainder = temp_remainder << 1;
        temp_remainder = temp_remainder | dividend[WIDTH-1];

        // subtract divisor
        if (temp_remainder >= divisor) begin
            remainder = temp_remainder - divisor;
            q <= q + 1;
        end else begin
            remainder = temp_remainder + divisor;   // restore
            q <= q;
        end
    end
end

always_comb begin
    valid = (quotient != 0);
end

endmodule
