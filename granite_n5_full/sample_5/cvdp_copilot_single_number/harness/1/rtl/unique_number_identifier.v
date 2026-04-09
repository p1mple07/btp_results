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

reg [p_bit_width-1:0] unique_number;
reg [p_bit_width-1:0] number_counter;
reg [p_bit_width-1:0] number_buffer;
reg ready_flag;

always @(posedge i_clk) begin
    if (i_rst_n == 0) begin
        unique_number <= 0;
        number_counter <= 0;
        number_buffer <= 0;
        ready_flag <= 0;
    end else if (i_ready &&!ready_flag) begin
        if (number_counter < p_max_numbers) begin
            number_buffer <= i_number;
            number_counter <= number_counter + 1;
            ready_flag <= 1;
        end else begin
            number_buffer <= {number_buffer[p_bit_width-2:0], i_number};
            unique_number <= number_buffer >> 1;
            ready_flag <= 0;
        end
    end else begin
        unique_number <= unique_number;
        ready_flag <= 0;
    end
end

assign o_unique_number = unique_number;

endmodule