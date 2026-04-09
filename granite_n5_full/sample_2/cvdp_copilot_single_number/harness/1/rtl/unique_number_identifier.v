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

reg [p_bit_width-1:0] counter;
reg [p_bit_width-1:0] unique_number;
reg [p_bit_width-1:0] next_number;
reg [p_bit_width-1:0] prev_number;

always @(posedge i_clk) begin
    if (i_rst_n == 1'b0) begin
        counter <= 0;
        unique_number <= 0;
    end else begin
        if (i_ready == 1'b1) begin
            unique_number <= next_number;
            next_number <= i_number;
            if (counter < p_max_numbers - 1) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
            end
        end
    end
end

assign o_unique_number = unique_number;

endmodule