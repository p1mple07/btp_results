module unique_number_identifier #(
    parameter p_bit_width = 8,
    parameter p_max_numbers = 16
) (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire [p_bit_width-1:0] i_number,
    output reg [p_bit_width-1:0] o_unique_number
);

    // Internal state
    reg [p_bit_width-1:0] unique_num_counter;
    reg [p_bit_width-1:0] number_counter;
    reg [p_bit_width-1:0] number_checksum;

    // State machine
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            unique_num_counter <= 0;
            number_counter <= 0;
            number_checksum <= 0;
        end else if (i_ready) begin
            unique_num_counter <= number_counter;
            number_counter <= number_counter + 1;
            number_checksum <= number_checksum ^ i_number;

            // Identify unique number
            if (unique_num_counter == number_counter) begin
                o_unique_number <= number_checksum;
            end else begin
                o_unique_number <= 0;
            end
        end
    end

endmodule
