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
                while (cycle_counter < 240) {
                    if (ir_signal_in && !bit_counter) {
                        present_state <= start;
                        bit_counter = 12;
                    }
                    bit_counter = bit_counter - 1;
                    cycle_counter = cycle_counter + 1;
                }
                // If start bit not detected in time, reset
                if (bit_counter != 0)
                    present_state <= idle;
                else
                    present_state <= start;
            start: begin
                bit_counter = 12;
                cycle_counter = 0;
                present_state <= decoding;
            decoding: begin
                while (cycle_counter < 12 * 120) {
                    // Read bit
                    logic low_pulse = ir_signal_in;
                    logic high_pulse = 1;

                    // Check if bit is 0 or 1
                    if (low_pulse && !high_pulse) {
                        ir_frame_reg[bit_counter] = 0;
                        high_pulse = 0;
                    } else if (!low_pulse && high_pulse) {
                        ir_frame_reg[bit_counter] = 1;
                    }

                    // Check validity of bit
                    if (bit_counter == 0 && (low_pulse || high_pulse != 1)) {
                        failed = 1;
                        present_state <= idle;
                        break;
                    }
                    if (bit_counter > 0 && (low_pulse != 0 || high_pulse != 1)) {
                        failed = 1;
                        present_state <= idle;
                        break;
                    }

                    cycle_counter = cycle_counter + 1;
                    bit_counter = bit_counter - 1;
                }
                if (failed)
                    present_state <= idle;
                else
                    present_state <= finish;
            finish: begin
                // Output latency
                present_state <= finish;
                // Wait one clock cycle
                while (cycle_counter < 120) {
                    cycle_counter = cycle_counter + 1;
                }
                ir_frame_valid = 1;
                present_state <= idle;
            end
        end
    end
endmodule