module adc_data_rotate #(
    parameter DATA_WIDTH = 8  // Parameterized data width
)(
    // Inputs
    input  logic                     i_clk,             // Clock signal
    input  logic                     i_rst_n,           // Active-low reset
    input  logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input  logic [3:0]               i_shift_count,     // Number of bits to shift (supports up to 15)
    input  logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    // Outputs
    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status (0: Reset, 1: Active)
);

    // Internal signal for temporary storage during rotation
    logic [DATA_WIDTH-1:0] temp;
    // Loop index for bit-wise processing
    integer k;
    // Effective shift count computed as modulo DATA_WIDTH
    int shift_val;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_processed_data <= '0;
            o_operation_status <= 0;
        end
        else begin
            o_operation_status <= 1;
            // Compute effective shift: i_shift_count modulo DATA_WIDTH
            shift_val = int'(i_shift_count) % DATA_WIDTH;

            // No rotation needed if shift_val is 0
            if (shift_val == 0)
                o_processed_data <= i_adc_data_in;
            // Left rotation: bits shifted out from the left re-enter on the right
            else if (i_shift_direction == 0) begin
                for (k = 0; k < DATA_WIDTH; k = k + 1) begin
                    temp[k] = i_adc_data_in[(k + shift_val) % DATA_WIDTH];
                end
                o_processed_data <= temp;
            end
            // Right rotation: bits shifted out from the right re-enter on the left
            else begin
                for (k = 0; k < DATA_WIDTH; k = k + 1) begin
                    temp[k] = i_adc_data_in[(k - shift_val + DATA_WIDTH) % DATA_WIDTH];
                end
                o_processed_data <= temp;
            end
        end
    end

endmodule