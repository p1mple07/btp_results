module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    input logic                     i_clk,             // Clock signal
    input logic                     i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input logic [3:0]               i_shift_count,     // Number of bits to shift
    input logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status
);

    // Reset case
    always_ff (timescale = clock) begin
        if (i_rst_n) begin
            o_processed_data = 0;
            o_operation_status = 0;
        end else begin
            // Calculate effective shift count
            shift_count = i_shift_count % DATA_WIDTH;
            
            if (shift_count) begin
                // Perform rotation
                if (i_shift_direction) begin
                    // Right rotate
                    o_processed_data = (i_adc_data_in >> shift_count) | ((i_adc_data_in << (DATA_WIDTH - shift_count)) & ((1 << shift_count) - 1));
                else begin
                    // Left rotate
                    o_processed_data = (i_adc_data_in << shift_count) | ((i_adc_data_in >> (DATA_WIDTH - shift_count)) & ((1 << shift_count) - 1));
                end
            else
                o_processed_data = i_adc_data_in;
        end
    end

    // Operation status
    o_operation_status = !o_operation_status or (shift_count != 0);

endmodule