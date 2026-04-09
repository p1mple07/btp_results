module adc_data_rotate #(
    parameter DATA_WIDTH = 8
)(
    input logic                     i_clk,             // Clock signal
    input logic                     i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input data
    input logic [3:0]               i_shift_count,     // Shift count
    input logic                     i_shift_direction, // Shift direction

    // Outputs
    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output
    output logic                    o_operation_status // Operation status
);

    // Reset handling
    always @(i_clk or i_rst_n) begin
        if (i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
        end else begin
            // Check if operation is active
            if (i_operation_status == 1) begin
                // Rotate the data
                logic [DATA_WIDTH-1:0] new_data;
                if (i_shift_direction == 0) begin
                    // Left rotate
                    new_data[0:shift_count-1] = i_adc_data_in[(DATA_WIDTH-1-shift_count+1):0];
                    new_data[shift_count:DATA_WIDTH-1] = i_adc_data_in[0:shift_count];
                else begin
                    // Right rotate
                    new_data[DATA_WIDTH-1-shift_count+1:DATA_WIDTH] = i_adc_data_in[0:shift_count-1];
                    new_data[0:DATA_WIDTH-1-shift_count] = i_adc_data_in[DATA_WIDTH-1-shift_count+1:];
                end
                o_processed_data <= new_data;
            end
            o_operation_status <= 1; // Set status to active
        end
    end

endmodule
