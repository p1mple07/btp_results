module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    input logic                     i_clk,             // Clock signal
    input logic                     i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input logic [3:0]               i_shift_count,     // Number of bits to shift
    input logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    output logic [DATA_WIDTH-1:0]  o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status
);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_processed_data <= 0;
      o_operation_status <= 0;
    end else begin
      case (i_shift_direction)
        0: o_processed_data <= {i_adc_data_in[i_shift_count-1:0], i_adc_data_in[DATA_WIDTH-1:i_shift_count]};
        1: o_processed_data <= {i_adc_data_in[DATA_WIDTH-1:i_shift_count], i_adc_data_in[i_shift_count-1:0]};
        default: o_processed_data <= i_adc_data_in; // Default case handles invalid shift directions
      endcase

      o_operation_status <= 1; // Set operation status to active
    end
  end

endmodule