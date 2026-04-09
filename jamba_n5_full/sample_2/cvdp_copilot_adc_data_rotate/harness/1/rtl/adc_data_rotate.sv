module adc_data_rotate #(
    parameter DATA_WIDTH = 8
)(
    // Inputs
    input logic                     i_clk,             // Clock signal
    input logic                     i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input logic [3:0]               i_shift_count,     // Number of bits to shift
    input logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    // Outputs
    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status
);

    // Internal variables
    reg [DATA_WIDTH-1:0] temp_data;
    reg operation_active;

    // Always block for clock cycle
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
            operation_active <= 0;
        end else begin
            operation_active = 1;

            if (i_shift_direction == 0) {
                temp_data = (i_adc_data_in << i_shift_count) 
                            | (i_adc_data_in >> (DATA_WIDTH - i_shift_count));
            } else {
                temp_data = (i_adc_data_in >> i_shift_count) 
                            | (i_adc_data_in << (DATA_WIDTH - i_shift_count));
            }

            o_processed_data <= temp_data;
            o_operation_status <= 1;
        end
    end

endmodule
