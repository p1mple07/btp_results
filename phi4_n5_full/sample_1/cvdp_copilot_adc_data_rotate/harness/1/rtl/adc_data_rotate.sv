module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    // Inputs
    input  logic                     i_clk,             // Clock signal
    input  logic                     i_rst_n,           // Active-low reset
    input  logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input  logic [3:0]               i_shift_count,     // Number of bits to shift
    input  logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    // Outputs
    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status
);

    // Synchronous process for rotation operation
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_processed_data  <= '0;
            o_operation_status<= 1'b0;
        end else begin
            // Calculate effective shift amount. If i_shift_count exceeds DATA_WIDTH,
            // no rotation is performed (shift_amount becomes 0).
            logic [DATA_WIDTH-1:0] shift_amount;
            if (i_shift_count >= DATA_WIDTH)
                shift_amount = 0;
            else
                shift_amount = i_shift_count;

            // If shift_amount is 0, no rotation is needed; data remains unchanged.
            if (shift_amount == 0) begin
                o_processed_data <= i_adc_data_in;
            end else if (i_shift_direction == 1'b0) begin
                // Left Rotate: Bits shifted out from the left re-enter on the right.
                o_processed_data <= { i_adc_data_in[DATA_WIDTH-shift_amount-1:0], i_adc_data_in[DATA_WIDTH-1:shift_amount] };
            end else begin
                // Right Rotate: Bits shifted out from the right re-enter on the left.
                o_processed_data <= { i_adc_data_in[shift_amount-1:0], i_adc_data_in[DATA_WIDTH-1:shift_amount] };
            end

            // Set operation status to active (1) if a rotation operation is performed.
            o_operation_status <= (shift_amount != 0);
        end
    end

endmodule