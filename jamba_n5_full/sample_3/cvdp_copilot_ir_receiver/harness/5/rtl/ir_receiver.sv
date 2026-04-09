module ir_receiver (
    input  logic reset_in,
    input  logic clk_in,
    input  logic ir_signal_in,
    output logic [6:0] ir_function_code_out,
    output logic [4:0] ir_device_address_out,
    output logic ir_output_valid
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

    // State machine transitions
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

            // Frame space monitoring
            case (frame_space)
                frame_space: begin
                    if (frame_space_counter > 45)
                        next_state = idle;
                    else
                        next_state = frame_space;
                end
                default: next_state = idle;
            end
        endcase
    end

    // Output generation after successful decoding
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            ir_function_code_out <= 7'b0;
            ir_device_address_out <= 5'b0;
            ir_output_valid <= 1'b0;
        else
            if (started && decoded == 1)
                ir_function_code_out <= ir_function_code;
            if (ir_output_valid == 1)
                ir_output_valid <= 1'b1;
        end
    end

endmodule
