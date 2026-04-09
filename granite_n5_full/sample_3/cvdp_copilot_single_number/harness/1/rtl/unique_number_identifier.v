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

// Unique Number Identifier Module
reg [p_bit_width-1:0] counter;
reg [p_bit_width-1:0] prev_number;
reg [p_bit_width-1:0] next_number;
reg [p_bit_width-1:0] unique_number;

always @(posedge i_clk) begin
    if (!i_rst_n) begin
        // Reset
        unique_number <= 0;
        counter <= 0;
        prev_number <= 0;
        next_number <= 0;
    end else begin
        // Detect ready signal
        if (i_ready) begin
            // Check if ready signal has been deserted
            if (counter == 0) begin
                // Update previous number
                prev_number <= i_number;
            end
            // Update next number
            next_number <= i_number;
            // Increment counter
            counter <= counter + 1;
        end
        // Check if counter equals max numbers
        if (counter == p_max_numbers) begin
            // Calculate unique number
            unique_number <= (prev_number ^ next_number);
            // Reset counter and previous number
            counter <= 0;
            prev_number <= 0;
        end
    end
end

assign o_unique_number = unique_number;

endmodule