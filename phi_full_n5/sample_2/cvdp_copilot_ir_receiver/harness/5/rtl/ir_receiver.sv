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

        // Decoding Logic
        case (ir_frame_out[6:0])
            // Function code decoding
            7'b000_0001: ir_function_code_out = 7'b1111111; failed = 0;
            7'b000_0010: ir_function_code_out = 7'b1111110; failed = 0;
            7'b000_0011: ir_function_code_out = 7'b1111101; failed = 0;
            7'b000_0100: ir_function_code_out = 7'b1111011; failed = 0;
            7'b000_0101: ir_function_code_out = 7'b1110111; failed = 0;
            7'b000_0110: ir_function_code_out = 7'b1101111; failed = 0;
            7'b000_0111: ir_function_code_out = 7'b1011111; failed = 0;
            7'b000_1000: ir_function_code_out = 7'b0111111; failed = 0;
            7'b000_1001: ir_function_code_out = 7'b0111110; failed = 0;
            7'b000_1010: ir_function_code_out = 7'b0111101; failed = 0;
            7'b000_1011: ir_function_code_out = 7'b0111011; failed = 0;
            7'b000_1100: ir_function_code_out = 7'b0110111; failed = 0;
            7'b000_1101: ir_function_code_out = 7'b0110110; failed = 0;
            7'b000_1110: ir_function_code_out = 7'b0110101; failed = 0;
            7'b000_1111: ir_function_code_out = 7'b0110011; failed = 0;
            default: failed = 1;

            // Device address decoding
            5'b00001: ir_device_address_out = 5'b10000; failed = 0;
            5'b00010: ir_device_address_out = 5'b10001; failed = 0;
            5'b00100: ir_device_address_out = 5'b10010; failed = 0;
            5'b01000: ir_device_address_out = 5'b10100; failed = 0;
            5'b10000: ir_device_address_out = 5'b11000; failed = 0;
            default: failed = 1;

            // Validity check
            if (failed == 1)
                success = 0;
            else
                success = 1;
        endcase
    end
end
