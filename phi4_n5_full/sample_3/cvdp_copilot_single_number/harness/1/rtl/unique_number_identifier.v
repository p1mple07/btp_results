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

    // Register to accumulate the XOR of all numbers seen so far.
    reg [p_bit_width-1:0] xor_reg;

    // Synchronous process with asynchronous active-low reset.
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            xor_reg <= {p_bit_width{1'b0}};
            o_unique_number <= {p_bit_width{1'b0}};
        end else begin
            if (i_ready) begin
                // XOR the incoming number with the current accumulator.
                xor_reg <= xor_reg ^ i_number;
            end
            // Continuously update the output with the current XOR result.
            o_unique_number <= xor_reg;
        end
    end

endmodule