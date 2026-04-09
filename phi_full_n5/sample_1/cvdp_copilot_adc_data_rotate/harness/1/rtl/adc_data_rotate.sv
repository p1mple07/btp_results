module adc_data_rotate #(
    parameter DATA_WIDTH = 8 // Parameterized data width
)(
    input logic                     i_clk,             // Clock signal
    input logic                     i_rst_n,           // Active-low reset
    input logic [DATA_WIDTH-1:0]    i_adc_data_in,     // Input ADC data
    input logic [3:0]               i_shift_count,     // Number of bits to shift
    input logic                     i_shift_direction, // Shift direction (0: Left, 1: Right)

    output logic [DATA_WIDTH-1:0]   o_processed_data,  // Rotated output data
    output logic                    o_operation_status // Operation status
);

    // State and control signals
    logic [DATA_WIDTH-1:0] shift_buffer;
    logic shift_active, reset_active;

    // Combinational logic for control signals
    assign shift_active = i_shift_direction != 0 && !i_rst_n;
    assign reset_active = i_rst_n;

    // State machine
    always_ff @(posedge i_clk) begin
        if (reset_active) begin
            shift_buffer <= {DATA_WIDTH{1'b0}};
            o_processed_data <= {DATA_WIDTH{1'b0}};
            o_operation_status <= 0;
        end else if (shift_active) begin
            case (i_shift_count)
                0: o_processed_data <= shift_buffer;
                DATA_WIDTH: shift_buffer <= i_adc_data_in;
                default: begin
                    if (i_shift_direction == 0) begin
                        shift_buffer <= {shift_buffer[DATA_WIDTH-1], shift_buffer[DATA_WIDTH-2]};
                    end else begin
                        shift_buffer <= {shift_buffer[1], shift_buffer[2:DATA_WIDTH-1]};
                    end
                end
            endcase
            o_operation_status <= 1;
        end
    end

endmodule
