module unique_number_identifier #(
    parameter p_bit_width = 8,
    parameter p_max_numbers = 16
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire [p_bit_width-1:0] i_number,
    output reg [p_bit_width-1:0] o_unique_number
);

    // On every rising edge of i_clk or asynchronous reset, update the accumulator.
    // The accumulator is maintained across i_ready deassertions.
    // When i_ready is asserted, the current input number is XORed into the accumulator.
    // When i_rst_n is low, the accumulator and output are reset to 0.
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_unique_number <= {p_bit_width{1'b0}};
        end else begin
            if (i_ready) begin
                o_unique_number <= o_unique_number ^ i_number;
            end
        end
    end

endmodule