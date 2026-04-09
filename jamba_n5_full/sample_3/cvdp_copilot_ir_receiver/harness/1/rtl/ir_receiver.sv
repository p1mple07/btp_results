module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] {idle, start, decoding, done} ir_state;
    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;

    int bit_counter;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in == 1'b1) begin
                    next_state = start;
                end else
                    next_state = idle;
                started = 0;
            end

            start: begin
                started = 1;
                // Check start bit
                if (ir_signal_in == 1'b0) begin
                    next_state = decoding;
                end else
                    next_state = idle;
                started = 0;
            end

            decoding: begin
                // Simulate bit reading
                for (bit=0; bit<12; bit++) begin
                    // Wait for bit pulse
                    while (!started) begin
                        #1;
                    end

                    // Assume bit is 1 (0.6ms high)
                    bit_valid = 1'b1;

                    // Check pulse duration: 0.6ms high
                    if (bit_counter % 2 == 0) begin
                        pulse_high_ok = 1'b1;
                    end else begin
                        pulse_high_ok = 1'b0;
                    end

                    bit_counter++;
                end

                decoded = bit_valid;
                ir_frame_valid = 1;
                success = 1;
            end

            done: begin
                decoded = 1'b0;
                ir_frame_valid = 0;
                success = 0;
                next_state = idle;
            end
        endcase
    end

endmodule
