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

    // FSM states
    state state = Idle;

    // Variables
    reg available_spaces = 0;
    reg count_car = 0;
    reg [7:0] seven_seg_display_available_tens = 0;
    reg [7:0] seven_seg_display_available_units = 0;
    reg [7:0] seven_seg_display_count_tens = 0;
    reg [7:0] seven_seg_display_count_units = 0;

    // 7-segment encoding functions
    function [7:0] sevenseg_digit(int input) {
        if (input == 0) return 0b0000000;
        if (input == 1) return 0b0000001;
        if (input == 2) return 0b0000010;
        if (input == 3) return 0b0000011;
        if (input == 4) return 0b0000100;
        if (input == 5) return 0b0000101;
        if (input == 6) return 0b0000110;
        if (input == 7) return 0b0000111;
        if (input == 8) return 0b0001000;
        if (input == 9) return 0b0001001;
        return 0b0000000;
    }

    always clock+1'~: 
        case (state)
            Idle:
                if (reset) 
                    state = Idle;
                    available_spaces = 0;
                    count_car = 0;
                    seven_seg_display_available_tens = 0;
                    seven_seg_display_available_units = 0;
                    seven_seg_display_count_tens = 0;
                    seven_seg_display_count_units = 0;
                else if (vehicle_entry_sensor) 
                    state = Entry Processing;
                else 
                    state = Idle;
            Entry Processing:
                if (vehicle_entry_sensor) 
                    state = Entry Processing;
                    available_spaces = available_spaces - 1;
                    count_car = count_car + 1;
                    seven_seg_display_available_tens = sevenseg_digit(available_spaces / 10);
                    seven_seg_display_available_units = sevenseg_digit(available_spaces % 10);
                    seven_seg_display_count_tens = sevenseg_digit(count_car / 10);
                    seven_seg_display_count_units = sevenseg_digit(count_car % 10);
                else 
                    state = Exit Processing;
            Exit Processing:
                if (vehicle_exit_sensor) 
                    state = Exit Processing;
                    available_spaces = available_spaces + 1;
                    count_car = count_car - 1;
                    seven_seg_display_available_tens = sevenseg_digit(available_spaces / 10);
                    seven_seg_display_available_units = sevenseg_digit(available_spaces % 10);
                    seven_seg_display_count_tens = sevenseg_digit(count_car / 10);
                    seven_seg_display_count_units = sevenseg_digit(count_car % 10);
                    state = Idle;
                else 
                    state = Exit Processing;
            Full:
                state = Full;
                led_status = 0;
        endcase
    endalways

    // Initial state
    initial begin
        $monitor clock;
        $monitor reset;
        $monitor vehicle_entry_sensor;
        $monitor vehicle_exit_sensor;
        $monitor available_spaces;
        $monitor count_car;
        $monitor led_status;
        $monitor seven_seg_display_available_tens;
        $monitor seven_seg_display_available_units;
        $monitor seven_seg_display_count_tens;
        $monitor seven_seg_display_count_units;
        forever $finish;
    end
endmodule