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

// Internal register to accumulate the XOR of all received numbers.
// The unique number is obtained by XOR-ing all numbers in the series,
// because every number (except the unique one) appears twice.
reg [p_bit_width-1:0] xor_acc;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        xor_acc <= 0;
        o_unique_number <= 0;
    end else begin
        if (i_ready) begin
            xor_acc <= xor_acc ^ i_number;
        end
        // Continuously update the output with the accumulated XOR.
        // When i_ready is deasserted, the previous value is retained.
        o_unique_number <= xor_acc;
    end
end

endmodule