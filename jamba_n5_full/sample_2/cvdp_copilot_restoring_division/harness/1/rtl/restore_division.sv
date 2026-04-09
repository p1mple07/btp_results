module restoring_division #(type WIDTH = 6) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output wire valid
);

reg [WIDTH-1:0] internal_remainder;
reg [WIDTH-1:0] temp_remainder;
reg [WIDTH-1:0] shift_value;
reg [WIDTH-1:0] div_sub;
reg [WIDTH-1:0] quot_bit;

initial begin
    internal_remainder = 0;
    valid = 0;
end

task generate_next_div;
    internal_remainder = internal_remainder << 1;
    temp_remainder = internal_remainder + (divisor >> 1);
    div_sub = dividend[WIDTH-1];
    if (div_sub >= temp_remainder) begin
        quot_bit = 1;
        remainder = temp_remainder - div_sub;
    else begin
        quot_bit = 0;
        remainder = temp_remainder;
    end
endtask

always @(posedge clk or posedge rst) begin
    if (!rst) begin
        internal_remainder <= 0;
        valid <= 0;
        quotient <= 0;
        remainder <= 0;
    end else if (start) begin
        // Start condition: only if we have already had a previous valid?
        // According to spec: "New inputs can be supplied along with start signal only when the previous outputs have been provided, indicated by the valid going high for one clock cycles."
        // So we can assume that after reset, we don't start until valid is high.
        // So we can just wait for start and then run the loop.
        if (start && valid) begin
            start <= 0;
            valid <= 1;
        end else begin
            // Not start, do nothing.
        end
    end
end

always @(posedge clk) begin
    if (valid) begin
        // Perform one iteration of restoring division
        generate_next_div;
    end
end

always @(posedge clk) begin
    if (valid && ~start) begin
        valid <= 0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        internal_remainder <= 0;
        valid <= 0;
        quotient <= 0;
        remainder <= 0;
    end
end

endmodule
