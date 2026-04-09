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
                bit_counter <= 0;
                started <= 1;
                frame_full <= 0;
                ir_frame_valid <= 0;
                if (ir_signal_in == '1) begin
                    ir_frame_out[bit_counter] <= ir_signal_in;
                    if (bit_counter == 11) begin
                        frame_full <= 1;
                        ir_frame_valid <= 1;
                    end
                    bit_counter <= bit_counter + 1;
                end
                else begin
                    failed <= 1;
                end
                if (frame_full && ir_frame_valid) begin
                    decoded <= 1;
                end
                else begin
                    decoded <= 0;
                end
            end
            finish: begin
                if (decoded == 1)
                    next_state = frame_space;
                else if (failed == 1)
                    next_state = idle;
                else
                    next_state = finish;
            end

            frame_space: begin
                if (frame_space_counter == 45) begin
                    frame_space_counter <= 0;
                    started <= 0;
                    ir_frame_valid <= 0;
                    decoded <= 0;
                    if (ir_signal_in == '1) begin
                        ir_frame_out[bit_counter] <= ir_signal_in;
                        bit_counter <= bit_counter + 1;
                        if (bit_counter == 11) begin
                            frame_full <= 1;
                            ir_frame_valid <= 1;
                        end
                    end
                    else begin
                        failed <= 1;
                    end
                end
                else begin
                    frame_space_counter <= frame_space_counter + 1;
                end
            end

            // Output logic for valid frame decoding
            case (ir_function_code_out)
                7'b1111111: ir_output_valid <= 1; ir_function_code_out <= 7'b00001; ir_device_address_out <= 5'b00001;
                7'b0011111: ir_output_valid <= 1; ir_function_code_out <= 7'b00011; ir_device_address_out <= 5'b00001;
                7'b0000000: ir_output_valid <= 1; ir_function_code_out <= 7'b00000; ir_device_address_out <= 5'b00000;
                // Additional cases for other function codes
                default: ir_output_valid <= 0;
            endcase

        endcase
    end

    // Output logic with latency
    assign ir_output_valid = ~ir_output_valid & (cycle_counter == 3);

endmodule
