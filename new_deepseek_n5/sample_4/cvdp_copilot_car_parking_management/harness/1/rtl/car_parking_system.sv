module car_parking_system(
    input clock,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output available_spaces,
    output count_car,
    output led_status,
    output [6:0] seven_seg_display_available_tens,
    output [6:0] seven_seg_display_available_units,
    output [6:0] seven_seg_display_count_tens,
    output [6:0] seven_seg_display_count_units
);

    // FSM State Register
    reg state = 0; // 0:Idle, 1:Entry Processing, 2:Exit Processing, 3:Full

    // 7-Segment Display Components
    wire [6:0] sevenseg_available_tens = sevenseg_available_tens_gen();
    wire [6:0] sevenseg_available_units = sevenseg_available_units_gen();
    wire [6:0] sevenseg_count_tens = sevenseg_count_tens_gen();
    wire [6:0] sevenseg_count_units = sevenseg_count_units_gen();

    // State Transition Logic
    always clocked begin
        if (reset) begin
            state = 0;
            available_spaces = 12;
            count_car = 0;
            led_status = 1;
        end else begin
            case (state)
                0: 
                    if (vehicle_entry_sensor) begin
                        state = 1;
                        available_spaces = 12 - 1;
                        count_car = 0 + 1;
                    end
                1: 
                    if (vehicle_exit_sensor) begin
                        state = 2;
                        available_spaces = 11 + 1;
                        count_car = 1 - 1;
                    end else begin
                        available_spaces = 11;
                        count_car = 1;
                    end
                2: 
                    if (vehicle_entry_sensor) begin
                        state = 3;
                        available_spaces = 0 - 1;
                        count_car = 12 + 1;
                    end else begin
                        available_spaces = 12;
                        count_car = 12;
                    end
                3: 
                    if (vehicle_entry_sensor) begin
                        state = 1;
                        available_spaces = 12 - 1;
                        count_car = 12 + 1;
                    end
                default:
                    available_spaces = 0;
                    count_car = 0;
                    led_status = 0;
            end
        end
    end

    // 7-Segment Display Implementations
    sevenseg_available_tens_gen #(
        .n(available_spaces / 10),
        .r(available_spaces % 10)
    ) (
        output available_spaces_tens,
        output available_spaces_units
    );

    sevenseg_available_units_gen #(
        .n(available_spaces % 10)
    ) (
        output available_spaces_units
    );

    sevenseg_count_tens_gen #(
        .n(count_car / 10),
        .r(count_car % 10)
    ) (
        output count_car_tens,
        output count_car_units
    );

    sevenseg_count_units_gen #(
        .n(count_car % 10)
    ) (
        output count_car_units
    );

endmodule