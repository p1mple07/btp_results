module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
) (
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

    logic [DATA_WIDTH-1:0] tmp_data;

    always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            o_processed_data <= 0;
            o_operation_status <= 0;
        end else begin
            if (i_shift_count == 0 || i_shift_count > DATA_WIDTH) begin
                o_processed_data <= i_adc_data_in;
                o_operation_status <= 0;
            end else begin
                tmp_data = {DATA_WIDTH{1'b0}};
                case (i_shift_direction)
                    0: // Left Rotate
                        for (int i = 0; i < i_shift_count; i = i + 1) begin
                            tmp_data[DATA_WIDTH-i-1] <= i_adc_data_in[DATA_WIDTH-i-1];
                        end
                        o_processed_data <= tmp_data;
                        o_operation_status <= 1;
                        break;
                    1: // Right Rotate
                        for (int i = DATA_WIDTH-1; i >= i_shift_count; i = i - 1) begin
                            tmp_data[i] <= i_adc_data_in[i-i_shift_count];
                        end
                        for (int i = i_shift_count; i < DATA_WIDTH-1; i = i + 1) begin
                            tmp_data[i] <= i_adc_data_in[i-1];
                        end
                        o_processed_data <= tmp_data;
                        o_operation_status <= 1;
                        break;
                endcase
            end
        end
    end

endmodule
