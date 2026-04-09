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

    // Internal signals
    logic [DATA_WIDTH-1:0] temp_data;

    // Reset logic
    always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            temp_data <= {DATA_WIDTH{1'b0}};
            o_operation_status <= 0;
        end else begin
            if (i_shift_count == 0) begin
                temp_data <= i_adc_data_in;
                o_operation_status <= 1;
            end else if (i_shift_count > DATA_WIDTH) begin
                temp_data <= {DATA_WIDTH{1'b0}};
                o_operation_status <= 1;
            end else begin
                case (i_shift_direction)
                    0: temp_data <= {i_shift_count{i_adc_data_in[DATA_WIDTH-i_shift_count:DATA_WIDTH-1]}, i_adc_data_in[0:DATA_WIDTH-i_shift_count-1]};
                    1: temp_data <= {i_adc_data_in[(DATA_WIDTH-i_shift_count+1):DATA_WIDTH], i_adc_data_in[0:DATA_WIDTH-i_shift_count-1]};
                endcase
                o_operation_status <= 1;
            end
        end
    end

    // Output assignment
    assign o_processed_data = temp_data;

endmodule
