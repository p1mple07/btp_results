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

    // Internal registers
    reg [p_bit_width-1:0] number_counter [0:p_max_numbers-1];
    reg [p_bit_width-1:0] number_count [0:p_max_numbers-1];
    reg [p_bit_width-1:0] unique_number;

    // State machine
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            // Reset all counters and unique number
            number_counter <= {p_max_numbers{1'b0}};
            number_count <= {p_max_numbers{1'b0}};
            unique_number <= 0;
        end else if (i_ready) begin
            // Increment counters based on input number
            number_counter <= number_counter + {i_number{1'b1}};
            number_count <= number_count + 1;

            // Identify unique number
            if (number_count[number_counter] == 1) begin
                unique_number <= i_number;
            end
        end
    end

    // Output logic
    always @(o_unique_number) begin
        o_unique_number <= unique_number;
    end

endmodule
