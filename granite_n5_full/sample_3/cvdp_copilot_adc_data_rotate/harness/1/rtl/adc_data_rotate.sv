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

    // Local parameters
    localparam NUM_BITS = $clog2(DATA_WIDTH); // Number of bits in the data width
    localparam LEFT_ROTATE = 0;              // Left rotate shift amount
    localparam RIGHT_ROTATE = 1;             // Right rotate shift amount

    // Internal signals
    logic [NUM_BITS-1:0] temp_shift_amount; // Temporarily stored shift amount
    logic [DATA_WIDTH-1:0] temp_data;         // Temporary storage for shifted data
    logic [DATA_WIDTH-1:0] processed_data;    // Processed data after rotation

    // Generate the shift amount based on the shift direction
    always_comb begin
        if (i_shift_direction == LEFT_ROTATE) begin
            temp_shift_amount = i_shift_count;
        end else begin
            temp_shift_amount = NUM_BITS - 1 - i_shift_count;
        end
    end

    // Perform the rotation based on the shift direction
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            processed_data <= 0;
            o_operation_status <= 0;
        end else begin
            case (i_shift_direction)
                LEFT_ROTATE: begin
                    processed_data <= {i_adc_data_in[temp_shift_amount-1:0], i_adc_data_in[DATA_WIDTH-1:temp_shift_amount]};
                end
                RIGHT_ROTATE: begin
                    processed_data <= {i_adc_data_in[DATA_WIDTH-1:i_shift_count], i_adc_data_in[i_shift_count-1:0]};
                end
            endcase

            o_processed_data <= processed_data;
            o_operation_status <= 1;
        end
    end

endmodule