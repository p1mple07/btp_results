module SetBitStreamCalculator(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire [7:0] i_bit_in, // Assuming a 8-bit input for i_bit_in
    output reg [7:0] o_set_bit_count
);

    parameter P_MAX_SET_BIT_COUNT_WIDTH = 8;
    reg [P_MAX_SET_BIT_COUNT_WIDTH-1:0] count_reg;

    // Asynchronous reset
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            count_reg <= 0;
        end
        else if (i_ready) begin
            count_reg <= 0;
        end
        else begin
            count_reg <= count_reg + (i_bit_in == 1'b1);
        end
    end

    // Saturation logic
    always @(posedge i_clk) begin
        if (count_reg > (2**P_MAX_SET_BIT_COUNT_WIDTH - 1)) begin
            count_reg <= (2**P_MAX_SET_BIT_COUNT_WIDTH - 1);
        end
        o_set_bit_count <= count_reg;
    end

endmodule
