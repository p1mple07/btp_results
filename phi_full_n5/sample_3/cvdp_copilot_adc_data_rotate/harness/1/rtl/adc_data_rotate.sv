module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    // Inputs
    input logic i_clk,             // Clock signal
    input logic i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0] i_adc_data_in,     // Input ADC data
    input logic [3:0] i_shift_count,     // Number of bits to shift
    input logic i_shift_direction, // Shift direction (0: Left, 1: Right)

    // Outputs
    output logic [DATA_WIDTH-1:0] o_processed_data,  // Rotated output data
    output logic o_operation_status // Operation status
);

    // Local variables
    logic [DATA_WIDTH-1:0] temp_data;
    logic rotate_active;

    // Reset logic
    always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
            temp_data <= 0;
        end else begin
            temp_data <= i_adc_data_in;
            o_operation_status <= 1;
        end
    end

    // Rotation logic
    always_ff @(posedge i_clk) begin
        if (i_shift_direction == 0) begin
            rotate_active = (i_shift_count > 0);
            temp_data = rotate_left(temp_data, i_shift_count);
        end else begin
            rotate_active = (i_shift_count <= DATA_WIDTH - 1);
            temp_data = rotate_right(temp_data, i_shift_count);
        end

        if (rotate_active) begin
            o_processed_data <= temp_data;
        end
        o_operation_status <= 1;
    end

    // Helper functions for rotation
    function logic [DATA_WIDTH-1:0] rotate_left(logic [DATA_WIDTH-1:0] data, logic count);
        rotate_left = data << count;
    endfunction

    function logic [DATA_WIDTH-1:0] rotate_right(logic [DATA_WIDTH-1:0] data, logic count);
        rotate_right = data >> count;
    endfunction

endmodule
