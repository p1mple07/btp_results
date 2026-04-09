module adc_data_rotate #(
    parameter DATA_WIDTH = 8
)(
    input logic                     i_clk,
    input logic                     i_rst_n,
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,
    input logic [3:0]               i_shift_count,
    input logic                     i_shift_direction,

    output logic [DATA_WIDTH-1:0]   o_processed_data,
    output logic                    o_operation_status
);

    // Reset on inactive reset
    always_comb begin
        if (i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
        end else begin
            if (i_shift_count == 0) begin
                o_processed_data <= i_adc_data_in;
                o_operation_status <= 0;
            end else begin
                if (i_shift_direction == 0) begin
                    // Left rotation: shift out leftmost bits and bring them to the right
                    o_processed_data <= {i_adc_data_in[DATA_WIDTH-1]} << i_shift_count
                                      | {i_adc_data_in[0:(DATA_WIDTH-1)-i_shift_count]};
                end else if (i_shift_direction == 1) begin
                    // Right rotation: shift out rightmost bits and bring them to the left
                    o_processed_data <= (i_adc_data_in >> i_shift_count) << (DATA_WIDTH - i_shift_count);
                end
                o_operation_status <= 1;
            end
        end
    end

endmodule
