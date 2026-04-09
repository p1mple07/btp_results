module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    input logic i_clk,     // Clock signal
    input logic i_rst_n,   // Active-low reset
    input logic [DATA_WIDTH-1:0] i_adc_data_in, // Input ADC data
    input logic [3:0] i_shift_count,     // Number of bits to shift
    input logic i_shift_direction, // Shift direction (0: Left, 1: Right)
    output logic [DATA_WIDTH-1:0] o_processed_data, // Rotated output data
    output logic o_operation_status // Operation status
);

    reg logic [DATA_WIDTH-1:0] shifted_data;
    reg logic [DATA_WIDTH-1:0] result;
    reg logic operation_state;

    // Initialize state variables
    always_comb begin
        if (i_rst_n) begin
            o_processed_data = 0;
            o_operation_status = 0;
            shifted_data = 0;
            result = 0;
            operation_state = 0;
        else begin
            // Calculate effective shift count
            integer effective_shift = i_shift_count[3:0] % DATA_WIDTH;
            if (effective_shift == 0 || effective_shift == DATA_WIDTH) begin
                // No rotation needed
                result = i_adc_data_in;
            else begin
                // Perform rotation
                if (i_shift_direction) begin
                    // Right rotate
                    result = (i_adc_data_in >> effective_shift) | ((i_adc_data_in << (DATA_WIDTH - effective_shift)) & ((1 << effective_shift) - 1));
                else begin
                    // Left rotate
                    result = (i_adc_data_in << effective_shift) | ((i_adc_data_in >> (DATA_WIDTH - effective_shift)) & ((1 << effective_shift) - 1));
                end
            end
            o_processed_data = result;
            o_operation_status = 1;
        end
    end

    // Update state variables on clock edge
    always positive_edge begin
        operation_state = 0;
    end

    // Ensure proper state transitions
    always begin
        if (i_rst_n) begin
            operation_state = 0;
        else if (o_operation_status) begin
            operation_state = 1;
        else begin
            operation_state = 0;
        end
    end

endmodule