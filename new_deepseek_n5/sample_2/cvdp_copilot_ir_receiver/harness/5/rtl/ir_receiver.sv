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

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;
    logic stored;

    logic frame_space_counter;
    logic bit_counter;

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
                if (bit_counter == 12 && ir_frame_valid == 1)
                    next_state = finish;
                else if (failed == 1)
                    next_state = idle;
                else
                    next_state = decoding;
            end
            finish: begin
                if (success == 1)
                    next_state = frame_space;
                    bit_counter = 0;
                    frame_full = 1;
                    ir_frame_valid = 1;
                else
                    next_state = finish;
            end
            frame_space: begin
                if (frame_full == 1)
                    frame_full = 0;
                    frame_space_counter = 0;
                    next_state = idle;
                else
                    frame_space_counter++;
                    next_state = frame_space;
                    if (frame_space_counter == 45)
                        next_state = idle;
            end
        end
    end

    // Bit decoding logic
    logic [11:0] current_bit;
    logic bit_value;

    always_comb begin
        case (present_state)
            idle: current_bit = 0;
            start: current_bit = 0;
            decoding: begin
                current_bit = ir_signal_in;
                if (current_bit == 1) begin
                    // 0 is LOW pulse of 0.6ms, 1 is LOW pulse of 1.2ms
                    ir_frame_reg[bit_counter] = current_bit;
                    bit_counter++;
                end
            end
            finish: begin
                ir_frame_out = ir_frame_reg;
                success = 1;
                ir_output_valid = 1;
            end
        end
    end

    // Function and address decoding
    always_comb begin
        case (ir_frame_out)
            12'b001000010110: ir_function_code_out = 7'b1111111;
            12'b000000010000: ir_function_code_out = 7'b0011111;
            // ... (add all function/address mappings)
        end
    end