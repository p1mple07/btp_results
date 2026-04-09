module SetBitStreamCalculator(
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    input wire [7:0] i_bit_in,
    output reg [7:0] o_set_bit_count
);

parameter p_max_set_bit_count_width = 8; // Maximum bit-width of o_set_bit_count
localparam MAX_SET_BIT_COUNT = (1 << p_max_set_bit_count_width) - 1; // Calculate the maximum count value

reg [7:0] internal_count = 0; // Internal register to store the current count value

always @(posedge i_clk or posedge i_rst_n) begin
    if (!i_rst_n) begin
        internal_count <= 0; // Reset the internal counter on reset
    end else if (i_ready) begin
        if (internal_count < MAX_SET_BIT_COUNT && i_bit_in == 1) begin
            internal_count <= internal_count + 1; // Increment the internal counter for each valid bit input
        end
    end
end

assign o_set_bit_count = internal_count; // Assign the internal count value to the output port

endmodule