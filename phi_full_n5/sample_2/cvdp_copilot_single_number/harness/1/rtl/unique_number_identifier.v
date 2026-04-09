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

    // Internal state storage
    reg [p_bit_width-1:0] number_count [0:p_max_numbers-1];
    reg [p_bit_width-1:0] unique_number;

    // State machine
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            // Reset internal states
            number_count <= {p_bit_width{1'b0}};
            unique_number <= 0;
        end else if (i_ready) begin
            // Count occurrences of each number
            number_count <= number_count + {i_number, number_count[i_number]};

            // Identify unique number
            for (int i=0; i<p_max_numbers; i++) begin
                if (number_count[i] == 1) begin
                    unique_number <= i_number;
                    break;
                end
            end
        end
    end

    // Output logic
    always @(i_ready or unique_number) begin
        if (i_ready) begin
            o_unique_number <= unique_number;
        end
    end

endmodule
