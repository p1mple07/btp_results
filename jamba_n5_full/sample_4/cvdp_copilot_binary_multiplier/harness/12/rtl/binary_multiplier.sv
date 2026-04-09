module binary_multiplier #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    input  logic               valid_in,
    output logic [2*WIDTH-1:0] Product,
    output logic               valid_out
);

reg start;
reg [WIDTH-1:0] accumulator;
reg [2*WIDTH-1:0] product;

initial begin
    start = 0;
end

always @(posedge clk) begin
    if (!rst_n) begin
        start <= 0;
        accumulator <= 0;
        product <= 0;
        valid_out <= 1'b0;
    end else begin
        if (start) begin
            if (valid_in) begin
                for (i = 0; i < WIDTH; i = i + 1) begin
                    if (A[i]) begin
                        accumulator = accumulator + (B << i);
                    end
                end
            end
            product = accumulator;
            valid_out = 1'b1;
        end else begin
            valid_out = 1'b0;
        end
    end
end

always_ff @(posedge rst_n) begin
    start <= 0;
    product <= 0;
    valid_out <= 1'b0;
end

endmodule
