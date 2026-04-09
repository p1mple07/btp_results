
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

        // Insert code for decoding and frame space logic here
