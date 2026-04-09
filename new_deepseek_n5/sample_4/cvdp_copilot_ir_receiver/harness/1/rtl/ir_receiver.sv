module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
    ir_state present_state, next_state;

    logic started; 
    logic decoded; 
    logic failed; 
    logic success;

    int cycle_counter; 
    int bit_counter;          

    logic [11:0] ir_frame_reg; 
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
                // Start bit detection
                if (!start && edge检测) 
                    present_state <= start;
                // If start bit not detected, reset
                else 
                    present_state <= idle;
            end

            start: begin
                // Data bit decoding
                bit_counter = 0;
                started = true;
                success = true;
                while (bit_counter < 12) begin
                    // Read next bit
                    ir_frame_reg = next_bit_value;
                    bit_counter = bit_counter + 1;
                    // Check if all bits are read
                    if (bit_counter == 12) begin
                        present_state <= finish;
                        // Set valid after 1 clock cycle
                        ir_frame_valid = 1;
                        // Reset on next clock cycle
                        ir_frame_valid = 0;
                    end
                end
            end

            decoding: begin
                // Validation of current bit
                if (!success) begin
                    started = false;
                    present_state <= idle;
                    next_state = idle;
                    continue;
                end
            end

            finish: begin
                // Set valid after 1 clock cycle
                ir_frame_valid = 1;
                // Reset on next clock cycle
                ir_frame_valid = 0;
            end
        end
    end

    // State transition logic
    process (present_state)
    begin
        case (present_state)
            idle: 
                next_state = start if start condition is met else idle;
            start: 
                next_state = decoding;
            decoding: 
                if (success) next_state = finish else next_state = idle;
            finish: 
                next_state = idle;
        endcase
    end

    // Bit value detection (example implementation)
    logic next_bit_value;
    always_comb begin
        next_bit_value = 0;
        // Implement bit value detection logic here
    end
endmodule