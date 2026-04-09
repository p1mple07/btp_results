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
                // Check for reset and start condition
                if (reset_in && !started) begin
                    next_state = start;
                    // reset other variables
                end else if (!reset_in)
                    next_state = idle;
                end else
                    next_state = next_state;
            end

            start: begin
                // Wait for start bit
                if (!started && ir_signal_in[11:0] == 4'b10000000) begin
                    next_state = decoding;
                end else
                    next_state = idle;
            end

            decoding: begin
                // Wait for each data bit with timing
                // This is complex, but we can use simple checks for now
                if (ir_signal_in[11:0] matches pattern) begin
                    // store in ir_frame_reg
                end
                // After 12 bits, move to finish
                if (bit_counter == 12)
                    next_state = finish;
                else
                    next_state = decoding;
            end

            finish: begin
                // Output the frame
                ir_frame_out = ir_frame_reg;
                ir_frame_valid = 1;
                next_state = idle;
            end

        endcase
    end

endmodule
