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
            end

            // Decoding logic
            decoding: begin
                if (bit_counter == 12) begin
                    frame_full = 1;
                    ir_frame_valid = 1;
                    bit_counter = 0;
                end
                bit_counter = bit_counter + 1;
                ir_frame_reg[bit_counter] = ir_signal_in;
                next_state = decoding;
            end
        end
    end

    // Address decoding
    decoding: begin
        logic [4:0] address = ir_frame_reg[10:5];
        ir_device_address_out = address;
    end

    // Function code decoding
    decoding: begin
        logic [7:0] function_code = ir_frame_reg[5:0];
        case (function_code)
            0b0000000 => ir_function_code_out = 7'b0000000;
            0b0000001 => ir_function_code_out = 7'b0000001;
            0b0000002 => ir_function_code_out = 7'b0000010;
            0b0000003 => ir_function_code_out = 7'b0000011;
            0b0000004 => ir_function_code_out = 7'b0000100;
            0b0000005 => ir_function_code_out = 7'b0000101;
            0b0000006 => ir_function_code_out = 7'b0000110;
            0b0000007 => ir_function_code_out = 7'b0000111;
            0b0000010 => ir_function_code_out = 7'b0001000;
            0b0000011 => ir_function_code_out = 7'b0001001;
            0b0000012 => ir_function_code_out = 7'b0001010;
            0b0000013 => ir_function_code_out = 7'b0001011;
            0b0000014 => ir_function_code_out = 7'b0001100;
            0b0000015 => ir_function_code_out = 7'b0001101;
            0b0000016 => ir_function_code_out = 7'b0001110;
            0b0000017 => ir_function_code_out = 7'b0001111;
            0b0000018 => ir_function_code_out = 7'b0010000;
            0b0000019 => ir_function_code_out = 7'b0010001;
            0b0000020 => ir_function_code_out = 7'b0010010;
            0b0000021 => ir_function_code_out = 7'b0010011;
            0b0000022 => ir_function_code_out = 7'b0010100;
            0b0000023 => ir_function_code_out = 7'b0010101;
            0b0000024 => ir_function_code_out = 7'b0010110;
            0b0000025 => ir_function_code_out = 7'b0010111;
            0b0000026 => ir_function_code_out = 7'b0011000;
            0b0000027 => ir_function_code_out = 7'b0011001;
            0b0000028 => ir_function_code_out = 7'b0011010;
            0b0000029 => ir_function_code_out = 7'b0011011;
            0b0000030 => ir_function_code_out = 7'b0011100;
            0b0000031 => ir_function_code_out = 7'b0011101;
            0b0000032 => ir_function_code_out = 7'b0011110;
            0b0000033 => ir_function_code_out = 7'b0011111;
            default case begin
                ir_function_code_out = 7'b0000000;
                failed = 1;
            end
        end
    end

    finish: begin
        ir_output_valid = 1;
        present_state = frame_space;
        bit_counter = 0;
    end

    frame_space: begin
        present_state = idle;
    end
endmodule