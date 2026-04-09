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
                // Assert outputs
                ir_function_code_out <= stored[7:0];
                ir_device_address_out <= stored[5:0];
                ir_output_valid <= success;
            end
            frame_space: begin
                frame_space_counter <= frame_space_counter + 1;
                if (frame_space_counter == 45000) // 45ms at 10kHz
                    next_state = idle;
                else
                    next_state = frame_space;
                // Clear stored
                stored <= 0;
            end
        end
    end

    // Read start bit
    if (present_state == start) begin
        if (ir_signal_in == 1) begin
            started <= 1;
            bit_counter <= 0;
            ir_frame_reg <= 0;
            next_state = decoding;
        end else
            next_state = idle;
    end

    // Read data bits
    if (present_state == decoding) begin
        if (bit_counter < 12) begin
            if (ir_signal_in == 1) begin
                ir_frame_reg <= (ir_frame_reg << 1) | 1;
                bit_counter <= bit_counter + 1;
                next_state = decoding;
            end else begin
                ir_frame_reg <= (ir_frame_reg << 1) | 0;
                bit_counter <= bit_counter + 1;
                next_state = decoding;
            end
        end else begin
            ir_frame_valid <= 1;
            next_state = finish;
        end
    end

    // Extract function code and device address
    if (present_state == finish) begin
        ir_frame_out <= ir_frame_reg;
        success <= 1;
    end
endmodule