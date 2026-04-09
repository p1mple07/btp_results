module binary_multiplier #(
    parameter WIDTH = 32
)(
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    input logic valid_in,
    output logic [2*WIDTH-1:0] Product,
    output logic valid_out
);

    logic [2*WIDTH-1:0] sum;
    logic start;
    logic [WIDTH-1:0] b_reg;
    integer cycle;

    always @posedge(clk) begin
        if (rst_n) begin
            sum = 0;
            start = 0;
            valid_out = 0;
        end else begin
            if (valid_in) begin
                start = 1;
                a_reg = A;
                b_reg = B;
                sum = 0;
                cycle = 0;
            end else if (start) begin
                sum = 0;
                cycle = 0;
            end
        end
    end

    always @posedge(clk) begin
        if (start) begin
            if (cycle < WIDTH) begin
                sum = sum + (b_reg << cycle);
                cycle = cycle + 1;
            end else if (cycle == WIDTH) begin
                Product = sum;
                valid_out = 1;
            end
        end
    end
end

endmodule