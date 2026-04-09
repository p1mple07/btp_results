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
reg [p_max_numbers-1:0][p_bit_width-1:0] numbers;

always @(posedge i_clk) begin
    if (!i_rst_n) begin
        counter <= 0;
        unique_number <= 0;
        numbers <= '{default:'0};
    end else if (i_ready) begin
        // Shift existing numbers by one position
        for (int i = 0; i < p_max_numbers - 1; i++) begin
            numbers[i] <= numbers[i+1];
        end
        
        // Store the new number in the first slot
        numbers[p_max_numbers - 1] <= i_number;

        // Update the counter
        counter <= counter + 1;

        // Identify unique number
        if (counter > p_max_numbers / 2) begin
            unique_number <= numbers[p_max_numbers / 2];
        end else begin
            unique_number <= 0;
        end
    end
end

assign o_unique_number = unique_number;

endmodule