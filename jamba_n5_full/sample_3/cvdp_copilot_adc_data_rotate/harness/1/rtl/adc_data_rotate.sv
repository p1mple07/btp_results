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

    logic temp;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
        end else begin
            if (i_rst_n) begin
                o_processed_data <= 0;
                o_operation_status <= 0;
            end else begin
                temp = i_adc_data_in << shift_count;
                if (shift_direction == 0) begin
                    o_processed_data = (temp >> (DATA_WIDTH - shift_count)) | (temp << (DATA_WIDTH - shift_count));
                else begin
                    o_processed_data = (temp >> shift_count) | (temp << (DATA_WIDTH - shift_count));
                end
                o_operation_status <= 1;
            end
        end
    end

endmodule
