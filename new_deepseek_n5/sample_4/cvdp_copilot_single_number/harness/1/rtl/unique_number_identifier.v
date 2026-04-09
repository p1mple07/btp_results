module unique_number_identifier #( 
    parameter p_bit_width = 8, 
    parameter p_max_numbers = 16 
)(
    input wire i_clk, 
    input wire i_ready, 
    input wire i_number, 
    input [p_bit_width-1:0] i_number, 
    output reg [p_bit_width-1:0] o_unique_number 
);

// Internal state variables
reg current_unique [p_bit_width-1:0];
integer unpaired_count;

always i_clk positive edge, i_ready == 1:
    if (i_number >= 0 && i_number < (1 << p_bit_width)) {
        current_unique = i_number;
        counts[current_unique] = counts[current_unique] + 1;
        if (counts[current_unique] == 2) {
            current_unique = 0;
            counts[current_unique] = 0;
            unpaired_count -= 1;
        }
    }
always i_rst_n:
    counts = 0;
    current_unique = 0;
    unpaired_count = p_max_numbers;