module adc_data_rotate #(
    parameter DATA_WIDTH = 8
)(
    input logic i_clk, 
    input logic i_rst_n,
    input logic [DATA_WIDTH-1:0] i_adc_data_in,
    input logic [3:0] i_shift_count,
    input logic i_shift_direction
);
    // Reset logic
    alwaysposedge i_rst_n:
        o_operation_status = 0;
        o_processed_data = 0;
    // Rotation logic
    positiveedge i_clk:
        if (i_rst_n == 0) begin
            if (i_shift_count != 0) begin
                logic [DATA_WIDTH-1:0] shifted_data;
                case (i_shift_direction)
                    0: // Left rotate
                        shifted_data = i_adc_data_in << i_shift_count;
                        shifted_data = rotated_right(shifted_data, i_shift_count);
                    1: // Right rotate
                        shifted_data = i_adc_data_in >> i_shift_count;
                        shifted_data = rotated_left(shifted_data, i_shift_count);
                endcase
                o_processed_data = shifted_data;
                o_operation_status = 1;
            end
        end
endmodule