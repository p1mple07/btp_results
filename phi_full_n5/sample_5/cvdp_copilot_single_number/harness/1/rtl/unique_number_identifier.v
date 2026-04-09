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

    reg [p_bit_width-1:0] number_counter [0:p_max_numbers-1];
    reg [p_bit_width-1:0] temp_number;
    integer counter;

    // State machine to keep track of the number series
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            counter <= 0;
            temp_number <= 0;
            o_unique_number <= 0;
        end else if (i_ready) begin
            counter <= counter + 1;
            temp_number <= i_number;
            case (counter)
                1: begin
                    if (number_counter[0] != temp_number) begin
                        o_unique_number <= temp_number;
                    end
                    number_counter[0] <= temp_number;
                    number_counter[1] <= temp_number;
                end
                2: begin
                    if (number_counter[0] == temp_number) begin
                        o_unique_number <= 0;
                    end
                    number_counter[0] <= temp_number;
                    number_counter[1] <= temp_number;
                    number_counter[2] <= temp_number;
                end
                // Repeat the above case for p_max_numbers
                default: begin
                    o_unique_number <= 0;
                end
            end
        end
    end

endmodule
