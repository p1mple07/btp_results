module SetBitStreamCalculator(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire [7:0] i_bit_in,
    output reg [7:0] o_set_bit_count
);

    // Define parameter for maximum count width
    parameter P_MAX_SET_BIT_COUNT_WIDTH = 8;

    // Counter variable
    reg [P_MAX_SET_BIT_COUNT_WIDTH-1:0] count_reg = 0;

    // Reset logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            count_reg <= 0;
        end else if (i_ready) begin
            count_reg <= count_reg + i_bit_in;
        end
    end

    // Saturation logic
    always @(count_reg) begin
        if (count_reg > (2**P_MAX_SET_BIT_COUNT_WIDTH - 1)) begin
            count_reg <= (2**P_MAX_SET_BIT_COUNT_WIDTH - 1);
        end
    end

    // Output assignment
    assign o_set_bit_count = count_reg;

endmodule
