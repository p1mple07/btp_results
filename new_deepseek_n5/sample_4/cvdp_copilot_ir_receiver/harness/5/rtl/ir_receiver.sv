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
    logic frame_full;
    logic ir_frame_valid;

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;
    logic stored;

    logic bit_counter = 0;
    logic frame_full = 0;
    logic ir_output_valid = 0;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in == 1 && !started)
                    next_state = start;
                else
                    next_state = idle;
            end
            start: begin
                if (ir_signal_in == 0 && started)
                    next_state = decoding;
                else if (failed)
                    next_state = idle;
                else
                    next_state = start;
            end
            decoding: begin
                if (decoded && !failed)
                    next_state = finish;
                else if (bit_counter == 12)
                    next_state = decoding;
                else
                    next_state = decoding;
            end
            finish: begin
                if (success && !frame_full)
                    next_state = frame_space;
                    ir_output_valid = 1;
                    frame_full = 1;
                    frame_space_counter = 0;
                else
                    next_state = finish;
            end
            frame_space: begin
                frame_space_counter <= frame_space_counter + 1;
                if (frame_space_counter == 45)
                    next_state = idle;
                else
                    next_state = frame_space;
            end
        end
    end

    // Bit decoding logic
    always_comb begin
        case (present_state)
            idle: ir_frame_reg <= 0;
            start: ir_frame_reg <= 0;
            decoding: ir_frame_reg <= (ir_signal_in ? (1 << 11) : 0) + ir_frame_reg;
            finish: ir_frame_reg <= (ir_signal_in ? (1 << 11) : 0) + ir_frame_reg;
        end
    end

    // Address and function decoding
    always_comb begin
        case (present_state)
            finish: 
                if (ir_frame_valid) begin
                    ir_function_code_out <= (ir_frame_reg >> 5) & 0x7F;
                    ir_device_address_out <= (ir_frame_reg & 0x1F);
                    ir_output_valid <= 1;
                    frame_full <= 1;
                    frame_space_counter <= 0;
                end
        end
    end