module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
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

    // Local variables declaration
    logic [DATA_WIDTH-1:0]        l_rotated_data;  // Local variable to hold rotated data
    logic                           l_rotation_active; // Local variable to track rotation operation status
    
    // Process block to implement rotation logic
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            l_rotated_data <= 0; // Reset local variable
            l_rotation_active <= 0; // Reset local variable
        end else begin
            if (l_rotation_active) begin
                case (i_shift_direction)
                    0: begin
                        l_rotated_data[DATA_WIDTH-2:0] <= l_rotated_data[DATA_WIDTH-1:1]; // Left rotate
                        l_rotated_data[DATA_WIDTH-1] <= i_adc_data_in[0];
                    end
                    1: begin
                        l_rotated_data[DATA_WIDTH-1:1] <= l_rotated_data[DATA_WIDTH-2:0]; // Right rotate
                        l_rotated_data[0] <= i_adc_data_in[DATA_WIDTH-1];
                    end
                endcase
            end else begin
                l_rotated_data <= i_adc_data_in; // No rotation, assign input data immediately
            end
        end
    end
    
    // Assign rotated data to output port
    assign o_processed_data = l_rotated_data;
    
    // Assign operation status to output port
    assign o_operation_status = l_rotation_active;

endmodule