module SetBitStreamCalculator #(
    parameter int p_max_set_bit_count_width = 8 // Maximum bit width of o_set_bit_count
) (
    input wire i_clk, // Positive edge triggered
    input wire i_reset_n, // Asynchronous active-low reset
    input wire i_ready, // Asserted when ready to count set bits
    input wire [p_max_set_bit_count_width-1:0] i_bit_in, // Single-bit stream input
    output reg [p_max_set_bit_count_width-1:0] o_set_bit_count // Total count of set bits received
);

reg [p_max_set_bit_count_width-1:0] count; // Running count of set bits

always @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
        count <= 0; // Reset to 0 on negative edge of reset
    end else begin
        if (i_ready && i_bit_in == 1'b1) begin
            count <= count + 1; // Increment count when i_bit_in is 1
        end
    end
end

assign o_set_bit_count = (count > (2**p_max_set_bit_count_width - 1))? // Check for saturation
                             (2**p_max_set_bit_count_width - 1) : // Return maximum value if saturated
                             count; // Return actual count

endmodule