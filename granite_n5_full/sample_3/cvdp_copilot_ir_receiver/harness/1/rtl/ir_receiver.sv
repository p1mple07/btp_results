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
                // Check for the start condition of 2.4 ms long LOW pulse
                if (ir_signal_in == 0 && cycle_counter >= 2) begin
                    started = 1;
                    cycle_counter = 0;
                end else if (started == 1) begin
                    cycle_counter++;
                end else begin
                    present_state <= idle;
                end
            end

            start: begin
                // Check for the 0.6 ms duration of the first bit
                if (ir_signal_in == 1 && bit_counter == 0) begin
                    bit_counter++;
                end else if (ir_signal_in == 0 && bit_counter == 1) begin
                    bit_counter++;
                } else if (ir_signal_in == 0 && bit_counter == 2) begin
                    bit_counter++;
                } else if (ir_signal_in == 1 && bit_counter == 3) begin
                    bit_counter++;
                    next_state <= decoding;
                end else if (ir_signal_in == 0 && bit_counter == 4) begin
                    bit_counter++;
                    next_state <= finish;
                end else begin
                    present_state <= start;
                end
            end

            decoding: begin
                // Check for the 1.2 ms duration of the second bit
                if (ir_signal_in == 1 && bit_counter == 3) begin
                    bit_counter++;
                    // Decode the bit value
                    //...
                end else if (ir_signal_in == 0 && bit_counter == 4) begin
                    bit_counter++;
                    // Store the decoded bit
                    //...
                    next_state <= finish;
                end else begin
                    present_state <= decoding;
                end
            end

            finish: begin
                // Check for the 1.2 ms duration of the third bit
                if (ir_signal_in == 0 && bit_counter == 2) begin
                    bit_counter++;
                    next_state <= idle;
                    ir_frame_valid = 1;
                end else begin
                    present_state <= finish;
                end
            end
        endcase
    end

endmodule