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

    // Internal state memory for storing input numbers
    reg [p_bit_width-1:0] number_storage [p_max_numbers-1:0];
    integer count;

    // State machine
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            count <= 0;
            o_unique_number <= 0;
            number_storage <= {p_bit_width{1'b0}};
        end else begin
            case (count)
                0: begin
                    if (i_ready) begin
                        number_storage[count] <= i_number;
                        count <= 1;
                    end
                end
                1: begin
                    if (i_number == number_storage[count-1]) begin
                        count <= count;
                    end else begin
                        count <= count + 1;
                        o_unique_number <= number_storage[count-1];
                    end
                end
                default: begin
                    o_unique_number <= 0;
                    count <= 0;
                end
            endcase
        end
    end

endmodule
