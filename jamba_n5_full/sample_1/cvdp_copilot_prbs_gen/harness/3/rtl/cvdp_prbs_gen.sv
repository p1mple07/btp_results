module cvdp_prbs_gen #(
    parameter INT CHECK_MODE = 0,
    int POLY_LENGTH = 31,
    int POLY_TAP = 3,
    int WIDTH = 16
) (
    input wire clk,
    input wire rst,
    input wire [WIDTH-1] data_in,
    output reg [WIDTH-1] data_out
);

localparam bool get_expected_bit(int i) = (i == 0 ? 1 : (prbs_reg[POLY_LENGTH-1] ^ prbs_reg[POLY_TAP]));

reg [WIDTH-1] prbs_reg;

initial begin
    if (rst)
        prbs_reg <= {WIDTH{1'b1}};
end

always @(posedge clk) begin
    if (rst)
        prbs_reg <= {WIDTH{1'b1}};
    else
        prbs_reg <= prbs_reg[WIDTH-1:]1b1;
end

always @(posedge clk) begin
    if (DATA_IN_VALID && !rst) begin
        data_in = 0;
    end
end

always @(posedge clk) begin
    if (rst)
        prbs_reg <= {WIDTH{1'b1}};
    else
        prbs_reg <= prbs_reg[WIDTH-1:]1b1;
end

always @(posedge clk) begin
    if (CHECK_MODE) begin
        always @(posedge clk) begin
            if (rst)
                data_out <= {WIDTH{1'b0}};
            else
                data_out <= {WIDTH{1'b0}};
        end
    end
    else begin
        always @(posedge clk) begin
            if (rst)
                prbs_reg <= {WIDTH{1'b1}};
            else
                prbs_reg <= prbs_reg[WIDTH-1:]1b1;
        end
        for (int i = 0; i < WIDTH; i++) begin
            int expected = get_expected_bit(i);
            int actual = prbs_reg[POLY_LENGTH-1] ^ prbs_reg[POLY_TAP];
            data_out[i] = data_in[i] ^ actual;
        end
    end
end
