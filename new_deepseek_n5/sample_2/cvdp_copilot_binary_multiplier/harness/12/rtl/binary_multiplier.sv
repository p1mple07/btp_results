module binary_multiplier #(
    parameter WIDTH = 32
)(
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    input logic valid_in,
    input logic rst_n,
    output logic [2*WIDTH-1:0] Product,
    output logic valid_out
);

    logic [WIDTH-1:0] a_reg, b_reg;
    logic [2*WIDTH-1:0] sum_reg;
    logic start, valid_in_reg;
    integer i;

    always @posedge clock begin
        if (rst_n) begin
            a_reg <= 0;
            b_reg <= 0;
            sum_reg <= 0;
            valid_out <= 0;
            return;
        end

        if (valid_in) begin
            start <= 1;
        end else begin
            start <= 0;
        end

        if (start) begin
            valid_in_reg <= 1;
            sum_reg <= 0;
            for (i = 0; i < WIDTH; i = i + 1) begin
                if (a_reg[i]) begin
                    sum_reg = sum_reg + (b_reg << i);
                end
            end
            Product <= sum_reg;
            valid_out <= 1;
        end else begin
            sum_reg <= 0;
            Product <= 0;
            valid_out <= 0;
        end
    end
endmodule