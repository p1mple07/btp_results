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

    // Module implementation here

endmodule