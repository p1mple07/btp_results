module adc_data_rotate #(
    parameter DATA_WIDTH = 8
)(
    input logic i_clk,
    input logic i_rst_n,
    input logic [DATA_WIDTH-1:0] i_adc_data_in,
    input logic [3:0] i_shift_count,
    input logic i_shift_direction,
    output logic [DATA_WIDTH-1:0] o_processed_data,
    output logic o_operation_status
);

    // Reset handling
    if (i_rst_n) begin
        o_operation_status = 0;
        o_processed_data = 0;
        // Wait for next clock cycle to reset
        wait;
    end else begin
        // Only perform rotation when reset is inactive
        case (i_shift_direction)
        // Left rotate
        0: begin
            // Calculate effective shift count
            shift_count = i_shift_count % DATA_WIDTH;
            if (shift_count == 0) begin
                o_processed_data = i_adc_data_in;
            else
                o_processed_data = (i_adc_data_in << shift_count) | (i_adc_data_in >> (DATA_WIDTH - shift_count));
            end
            o_operation_status = 1;
        end // Left rotate
        // Right rotate
        1: begin
            // Calculate effective shift count
            shift_count = i_shift_count % DATA_WIDTH;
            if (shift_count == 0) begin
                o_processed_data = i_adc_data_in;
            else
                o_processed_data = (i_adc_data_in >> shift_count) | ((i_adc_data_in << (DATA_WIDTH - shift_count)) >> (DATA_WIDTH - 1));
            end
            o_operation_status = 1;
        end // Right rotate
    end

endmodule