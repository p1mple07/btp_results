module binary_multiplier #(parameter WIDTH = 32) (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    input  logic A[WIDTH-1:0],
    input  logic B[WIDTH-1:0]
);

    reg start;
    reg valid_out;
    reg [WIDTH-1:0] product;
    reg [WIDTH-1:0] sum;
    reg [WIDTH-1:0] temp;
    integer i;

    always @(posedge clk) begin
        if (~rst_n) begin
            start = 0;
            valid_out = 0;
            product = 0;
            return;
        end

        start = valid_in;

        if (start) begin
            for (i = 0; i < WIDTH; i = i + 1) begin
                // Wait for WIDTH cycles
            end
        end

        if (start && valid_out) begin
            product = sum;
            valid_out = 1'b1;
        end else begin
            product = 0;
            valid_out = 1'b0;
        end
    end

endmodule
