// File: rtl/ir_receiver.sv
module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input IR signal
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    // State machine states
    typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
    ir_state present_state, next_state;

    // Counters for timing measurements
    int cycle_counter;   // Used in start (for 240 cycles) and in decoding low phase (for 60 cycles)
    int pulse_counter;   // Used in decoding high phase (for 60 or 120 cycles)
    int bit_counter;     // Counts the 12 data bits

    // Flag to indicate which phase of a data bit we are in: low pulse or high pulse
    logic low_phase;

    // Register to store the decoded IR frame
    logic [11:0] ir_frame_reg;

    // Sequential process: state register update and counter/phase management
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            present_state   <= idle;
            cycle_counter   <= 0;
            pulse_counter   <= 0;
            bit_counter     <= 0;
            low_phase       <= 0;
            ir_frame_out    <= 12'd0;
            ir_frame_valid  <= 0;
        end
        else begin
            case (present_state)
                idle: begin
                    // Wait for the start condition: IR signal goes high.
                    if (ir_signal_in)
                        next_state = start;
                    else
                        next_state = idle;
                    ir_frame_valid <= 0;
                end

                start: begin
                    // Count 240 cycles (2.4 ms) of a high pulse.
                    if (cycle_counter < 240) begin
                        if (ir_signal_in)
                            cycle_counter <= cycle_counter + 1;
                        else begin
                            // Signal went low too early: invalid start
                            next_state = idle;
                            cycle_counter <= 0;
                        end
                    end
                    else begin
                        // Valid start pulse detected.
                        next_state = decoding;
                        bit_counter <= 0;
                        low_phase   <= 1;  // Start decoding first data bit: low pulse phase
                        cycle_counter <= 0;
                        pulse_counter <= 0;
                    end
                    ir_frame_valid <= 0;
                end

                decoding: begin
                    if (low_phase) begin
                        // Low pulse phase: expect 60 cycles (0.6 ms) of a low signal.
                        if (cycle_counter < 60) begin
                            if (!ir_signal_in)
                                cycle_counter <= cycle_counter + 1;
                            else begin
                                // Went high too early: invalid timing
                                next_state = idle;
                                cycle_counter <= 0;
                            end
                        end
                        else begin
                            // Low pulse duration complete: expect transition to high.
                            if (ir_signal_in) begin
                                low_phase   <= 0;  // Switch to high pulse phase
                                pulse_counter <= 0;
                            end
                            else begin
                                // Did not go high as expected: error
                                next_state = idle;
                                cycle_counter <= 0;
                            end
                        end
                    end
                    else begin
                        // High pulse phase: count the duration.
                        if (pulse_counter < 120) begin
                            if (ir_signal_in)
                                pulse_counter <= pulse_counter + 1;
                            else begin
                                // Went low too early: error
                                next_state = idle;
                                pulse_counter <= 0;
                            end
                        end
                        else begin
                            // Check the high pulse duration to decide the bit value.
                            if (pulse_counter == 60) begin
                                // Bit 0: low pulse (60 cycles) followed by a high pulse of 60 cycles.
                                ir_frame_reg[bit_counter] <= 1'b0;
                                bit_counter <= bit_counter + 1;
                                if (bit_counter == 12) begin
                                    next_state = finish;
                                end
                                else begin
                                    low_phase <= 1;
                                    cycle_counter <= 0;
                                end
                            end
                            else if (pulse_counter == 120) begin
                                // Bit 1: low pulse (60 cycles) followed by a high pulse of 120 cycles.
                                ir_frame_reg[bit_counter] <= 1'b1;
                                bit_counter <= bit_counter + 1;
                                if (bit_counter == 12) begin
                                    next_state = finish;
                                end
                                else begin
                                    low_phase <= 1;
                                    cycle_counter <= 0;
                                end
                            end
                            else begin
                                // High pulse duration invalid (exceeds expected