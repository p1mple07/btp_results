module bcd_counter (
    input clock,
    input rst,
    output ms_hr, ls_hr,
    output ms_min, ls_min,
    output ms_sec, ls_sec
) {
    reg state = 0; // 0: seconds, 1: minutes, 2: hours

    reg[8] sec_counter, min_counter, hr_counter;

    always clock edge positive:
        case (state)
            0: 
                sec_counter = sec_counter + 1;
                if (sec_counter == 10) begin
                    sec_counter = 0;
                    min_counter = min_counter + 1;
                    state = 1;
                end
            1: 
                min_counter = min_counter + 1;
                if (min_counter == 60) begin
                    min_counter = 0;
                    hr_counter = hr_counter + 1;
                    state = 2;
                end
            2: 
                hr_counter = hr_counter + 1;
                if (hr_counter == 24) begin
                    hr_counter = 0;
                    state = 0;
                end
        endcase

        // Reset if rst is high
        if (rst) begin
            state = 0;
            sec_counter = 0;
            min_counter = 0;
            hr_counter = 0;
        end

        // Assign outputs
        ms_sec = (sec_counter >> 4) & 0x0F;
        ls_sec = sec_counter & 0x0F;
        ms_min = (min_counter >> 4) & 0x0F;
        ls_min = min_counter & 0x0F;
        ms_hr = (hr_counter >> 4) & 0x0F;
        ls_hr = hr_counter & 0x0F;
    endmodule