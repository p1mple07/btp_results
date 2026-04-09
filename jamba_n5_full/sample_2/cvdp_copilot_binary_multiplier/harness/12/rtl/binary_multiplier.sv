module binary_multiplier #(
    parameter WIDTH = 32
) (
    input clk,
    input rst_n,
    input valid_in,
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    output logic [2*WIDTH-1:0] Product,
    output logic valid_out
);

    localparam WIDTH_LOG = WIDTH;
    reg [WIDTH-1:0] temp_sum;
    reg start;
    reg [WIDTH-1:0] acc;
    reg finished;

    always @(posedge clk) begin
        if (rst_n) begin
            Product <= 0;
            valid_out <= 1'b0;
            start <= 0;
            acc <= 0;
            temp_sum <= 0;
            finished <= 0;
        end else begin
            start <= valid_in;
            if (start) begin
                acc <= 0;
                for (i = 0; i < WIDTH; i = i + 1) begin
                    if (A[i]) begin
                        temp_sum = temp_sum + (B << i);
                    end
                end
                Product = temp_sum;
                valid_out <= 1'b1;
            end else begin
                Product <= 0;
                valid_out <= 1'b0;
            end
        end
    end

endmodule
