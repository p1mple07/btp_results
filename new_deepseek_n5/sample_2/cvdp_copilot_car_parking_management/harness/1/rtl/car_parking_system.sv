module car_parking_system(
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

    // FSM State Register
    reg [3] state = 0; // 0:Idle, 1:Entry, 2:Exit, 3:Full

    // Counter
    reg [log2(TOTAL_SPACES)-1:0] available_spaces_counter = 0;
    reg [log2(TOTAL_SPACES)-1:0] count_car_counter = 0;

    // Seven Segment Encoders
    always_comb begin
        seven_seg_display_available_tens = encode7b(available_spaces_counter >> 1);
        seven_seg_display_available_units = encode7b(available_spaces_counter & 1);
        seven_seg_display_count_tens = encode7b(count_car_counter >> 1);
        seven_seg_display_count_units = encode7b(count_car_counter & 1);
    end

    // State Transition Table
    always clocked begin
        case(state)
            0: 
                if (reset) state = 0;
                else if (vehicle_entry_sensor) state = 1;
                else state = 0;
            1: 
                if (vehicle_entry_sensor) begin
                    available_spaces_counter = available_spaces_counter - 1;
                    count_car_counter = count_car_counter + 1;
                    if (available_spaces_counter == 0) state = 3;
                    else state = 1;
                end
            2: 
                if (vehicle_exit_sensor) begin
                    available_spaces_counter = available_spaces_counter + 1;
                    count_car_counter = count_car_counter - 1;
                    if (available_spaces_counter == TOTAL_SPACES) state = 0;
                    else state = 2;
                end
                else state = 2;
            3: 
                if (reset) state = 0;
                else state = 3;
        endcase
    end

    // LED
    available_spaces = (available_spaces_counter == 0) ? 1 : 0;
endmodule