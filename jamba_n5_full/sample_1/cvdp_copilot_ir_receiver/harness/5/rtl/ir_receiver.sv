module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us)
    input  logic        ir_signal_in,           // Input signal (IR)
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010":HDMI1, "00100":USB, "01000":HDMI2, "10000": VCR
    output logic        ir_output_valid         // Indicates validity of the decoded frame
);

    typedef enum logic [2:0] {idle, start, decoding, finish, frame_space} ir_state;
    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;
    logic frame_full;
    logic ir_frame_valid;

    int cycle_counter;
    int frame_space_counter;
    int bit_counter;

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;
    logic stored;

    // Reset logic
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in == 1 && started == 0)
                    next_state = start;
                else
                    next_state = idle;
            end
            start: begin
                if (ir_signal_in == 0 && started == 1)
                    next_state = decoding;
                else if (failed == 1)
                    next_state = idle;
                else
                    next_state = start;
            end
            decoding: begin
                if (decoded == 1)
                    next_state = finish;
                else if (failed == 1)
                    next_state = idle;
                else
                    next_state = decoding;
            end
            finish: begin
                if (success == 1)
                    next_state = frame_space;
                else
                    next_state = finish;
            end

            // Handle invalid frames
            default: next_state = idle;
        endcase
    end

    // After decoding, output the values
    always_ff @(posedge clk_in) begin
        if (ir_output_valid) begin
            ir_function_code_out = get_function_code(ir_frame_reg);
            ir_device_address_out = get_device_address(ir_frame_reg);
            ir_output_valid = 1;
        end else
            ir_function_code_out = 7'b0000000;
            ir_device_address_out = 5'b00000;
            ir_output_valid = 0;
        end
    end

endmodule
