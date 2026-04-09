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

    wire [DATA_WIDTH-1:0] rotated_data;

    always_comb if (i_rst_n) begin
        o_processed_data = 0;
        o_operation_status = 0;
    end

    clocked process (i_clk) begin
        if (i_rst_n) begin
            o_operation_status = 0;
            return;
        end

        integer effective_shift = i_shift_count % DATA_WIDTH;
        if (effective_shift == 0) begin
            o_processed_data = i_adc_data_in;
            o_operation_status = 1;
            return;
        end

        if (i_shift_direction) begin // Right rotate
            rotated_data = (i_adc_data_in >> effective_shift) | (i_adc_data_in << (DATA_WIDTH - effective_shift));
        else begin // Left rotate
            rotated_data = (i_adc_data_in << effective_shift) | (i_adc_data_in >> (DATA_WIDTH - effective_shift));
        end

        o_processed_data = rotated_data;
        o_operation_status = 1;
    end

endmodule