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

    logic [11:0] ir_frame_reg; 
    logic stored;
    reg cycle_counter;
    reg bit_counter;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                started = false;
                bit_counter = 0;
                ir_frame_reg = 0;
                next_state = start;
            end

            start: begin
                if (ir_signal_in & 1 && !bit_counter) begin
                    // Valid start bit transition
                    started = true;
                    bit_counter = 0;
                    next_state = decoding;
                end
                else
                    next_state = idle;
                end

            decoding: begin
                if (bit_counter < 12) begin
                    if (ir_signal_in & 1) begin
                        ir_frame_reg = ir_frame_reg + 1;
                        bit_counter = bit_counter + 1;
                        next_state = decoding;
                    end
                else
                    // All bits captured, check validity
                    if (bit_counter == 12) begin
                        success = true;
                        next_state = finish;
                    else begin
                        // Bit timing invalid
                        success = false;
                        failed = true;
                        next_state = idle;
                    end
                end
            end

            finish: begin
                // Output latency: 1 clock cycle
                ir_frame_valid = 1;
                next_state = idle;
            end
        end
    end

    // Store the final frame
    always @* begin
        stored = ir_frame_reg;
    end

    // Output the stored frame
    ir_frame_out = stored;
endmodule