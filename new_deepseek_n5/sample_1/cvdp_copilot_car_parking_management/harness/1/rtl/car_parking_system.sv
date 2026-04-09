module car_parking_system (
    input clock,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output available_spaces,
    output count_car,
    output led_status,
    output seven_seg_display_available_tens,
    output seven_seg_display_available_units,
    output seven_seg_display_count_tens,
    output seven_seg_display_count_units
);

    // State variables
    reg current_state = Idle;
    reg available_spaces = 12;
    reg count_car = 0;

    // 7-segment display segments (A-G)
    reg [7:0] seven_seg_available_tens = 0;
    reg [7:0] seven_seg_available_units = 0;
    reg [7:0] seven_seg_count_tens = 0;
    reg [7:0] seven_seg_count_units = 0;

    // FSM states
    always clocked begin
        case(current_state)
            Idle:
                if (reset) begin
                    current_state = Idle;
                    available_spaces = 12;
                    count_car = 0;
                    seven_seg_available_tens = 0b1100000;
                    seven_seg_available_units = 0b1100000;
                    seven_seg_count_tens = 0b0000000;
                    seven_seg_count_units = 0b0000000;
                end
                else if (vehicle_entry_sensor) begin
                    current_state = Entry Processing;
                end
                else begin
                    current_state = Idle;
                end
            Entry Processing:
                if (vehicle_entry_sensor) begin
                    if (available_spaces > 0) begin
                        available_spaces -== 1;
                        count_car +== 1;
                        seven_seg_available_tens = seven_seg_available_tens;
                        seven_seg_available_units = seven_seg_available_units;
                        seven_seg_count_tens = seven_seg_count_tens;
                        seven_seg_count_units = seven_seg_count_units;
                    else begin
                        led_status = 1;
                        seven_seg_available_tens = 0b0000000;
                        seven_seg_available_units = 0b0000000;
                        seven_seg_count_tens = 0b1111111;
                        seven_seg_count_units = 0b1111111;
                    end
                    vehicle_entry_sensor = 0;
                end
                else begin
                    current_state = Idle;
                end
            Exit Processing:
                if (vehicle_exit_sensor) begin
                    available_spaces +== 1;
                    count_car -== 1;
                    seven_seg_available_tens = seven_seg_available_tens;
                    seven_seg_available_units = seven_seg_available_units;
                    seven_seg_count_tens = seven_seg_count_tens;
                    seven_seg_count_units = seven_seg_count_units;
                    vehicle_exit_sensor = 0;
                end
                else begin
                    current_state = Idle;
                end
            Full:
                led_status = 0;
                seven_seg_available_tens = 0b1111111;
                seven_seg_available_units = 0b1111111;
                seven_seg_count_tens = 0b0000000;
                seven_seg_count_units = 0b0000000;
                vehicle_entry_sensor = 0;
                vehicle_exit_sensor = 0;
        endcase
    end

    // Encode available spaces to 7-segment displays
    always begin
        seven_seg_display_available_tens = encode_spaces(available_spaces, 2, 10);
        seven_seg_display_available_units = encode_spaces(available_spaces, 2, 10);
        seven_seg_display_count_tens = encode_spaces(count_car, 2, 10);
        seven_seg_display_count_units = encode_spaces(count_car, 2, 10);
    end

    // Encode function
    function encode_spaces(number, tens_bit, max) {
        if (number > max) number = max;
        if (number < 0) number = 0;
        return (number >> 1) & 0b1111111;
    }

endmodule