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
    enum state_state = {
        Idle,
        EntryProcessing,
        ExitProcessing,
        Full
    };

    // Current state
    reg state_state current_state, next_state;

    // Counters
    reg available_spaces_counter, count_car_counter;

    // Encoders
    reg [6:0] seg_a_available_tens, seg_b_available_tens, seg_c_available_tens, seg_d_available_tens, seg_e_available_tens, seg_f_available_tens,
              seg_a_available_units, seg_b_available_units, seg_c_available_units, seg_d_available_units, seg_e_available_units, seg_f_available_units,
              seg_a_count_tens, seg_b_count_tens, seg_c_count_tens, seg_d_count_tens, seg_e_count_tens, seg_f_count_tens,
              seg_a_count_units, seg_b_count_units, seg_c_count_units, seg_d_count_units, seg_e_count_units, seg_f_count_units;

    // State transitions
    always clocked begin
        case (current_state)
            Idle:
                next_state = Idle;
                available_spaces_counter = 12;
                count_car_counter = 0;
                if (vehicle_entry_sensor) next_state = EntryProcessing;
                if (vehicle_exit_sensor) next_state = ExitProcessing;
                led_status = 0;
                // Initialize displays
                seg_a_available_tens = 1;
                seg_b_available_tens = 1;
                seg_c_available_tens = 1;
                seg_d_available_tens = 1;
                seg_e_available_tens = 1;
                seg_f_available_tens = 1;
                seg_a_available_units = 1;
                seg_b_available_units = 1;
                seg_c_available_units = 1;
                seg_d_available_units = 1;
                seg_e_available_units = 1;
                seg_f_available_units = 1;
                seg_a_count_tens = 0;
                seg_b_count_tens = 0;
                seg_c_count_tens = 0;
                seg_d_count_tens = 0;
                seg_e_count_tens = 0;
                seg_f_count_tens = 0;
                seg_a_count_units = 0;
                seg_b_count_units = 0;
                seg_c_count_units = 0;
                seg_d_count_units = 0;
                seg_e_count_units = 0;
                seg_f_count_units = 0;
                end

            EntryProcessing:
                next_state = EntryProcessing;
                available_spaces_counter = available_spaces_counter - 1;
                count_car_counter = count_car_counter + 1;
                if (vehicle_entry_sensor) next_state = Full;
                led_status = 1;
                // Update displays
                seg_a_available_tens = 1;
                seg_b_available_tens = 1;
                seg_c_available_tens = 1;
                seg_d_available_tens = 1;
                seg_e_available_tens = 1;
                seg_f_available_tens = 1;
                seg_a_available_units = 2;
                seg_b_available_units = 2;
                seg_c_available_units = 1;
                seg_d_available_units = 1;
                seg_e_available_units = 1;
                seg_f_available_units = 1;
                seg_a_count_tens = 0;
                seg_b_count_tens = 0;
                seg_c_count_tens = 0;
                seg_d_count_tens = 0;
                seg_e_count_tens = 0;
                seg_f_count_tens = 0;
                seg_a_count_units = 0;
                seg_b_count_units = 1;
                seg_c_count_units = 0;
                seg_d_count_units = 0;
                seg_e_count_units = 0;
                seg_f_count_units = 0;
                end

            ExitProcessing:
                next_state = ExitProcessing;
                available_spaces_counter = available_spaces_counter + 1;
                count_car_counter = count_car_counter - 1;
                led_status = 0;
                // Update displays
                seg_a_available_tens = 1;
                seg_b_available_tens = 1;
                seg_c_available_tens = 1;
                seg_d_available_tens = 1;
                seg_e_available_tens = 1;
                seg_f_available_tens = 1;
                seg_a_available_units = 1;
                seg_b_available_units = 1;
                seg_c_available_units = 1;
                seg_d_available_units = 1;
                seg_e_available_units = 1;
                seg_f_available_units = 1;
                seg_a_count_tens = 1;
                seg_b_count_tens = 0;
                seg_c_count_tens = 0;
                seg_d_count_tens = 0;
                seg_e_count_tens = 0;
                seg_f_count_tens = 0;
                seg_a_count_units = 0;
                seg_b_count_units = 0;
                seg_c_count_units = 0;
                seg_d_count_units = 0;
                seg_e_count_units = 0;
                seg_f_count_units = 0;
                end

            Full:
                next_state = Full;
                available_spaces_counter = 0;
                count_car_counter = 12;
                led_status = 0;
                // Initialize displays
                seg_a_available_tens = 0;
                seg_b_available_tens = 0;
                seg_c_available_tens = 0;
                seg_d_available_tens = 0;
                seg_e_available_tens = 0;
                seg_f_available_tens = 0;
                seg_a_available_units = 0;
                seg_b_available_units = 0;
                seg_c_available_units = 0;
                seg_d_available_units = 0;
                seg_e_available_units = 0;
                seg_f_available_units = 0;
                seg_a_count_tens = 1;
                seg_b_count_tens = 1;
                seg_c_count_tens = 1;
                seg_d_count_tens = 1;
                seg_e_count_tens = 1;
                seg_f_count_tens = 1;
                seg_a_count_units = 2;
                seg_b_count_units = 2;
                seg_c_count_units = 1;
                seg_d_count_units = 1;
                seg_e_count_units = 1;
                seg_f_count_units = 1;
                end
        default:
            next_state = Idle;
    end

    // Encode available spaces
    always clocked begin
        seg_a_available_tens = (available_spaces_counter >> 5) & 1;
        seg_b_available_tens = (available_spaces_counter >> 4) & 1;
        seg_c_available_tens = (available_spaces_counter >> 3) & 1;
        seg_d_available_tens = (available_spaces_counter >> 2) & 1;
        seg_e_available_tens = (available_spaces_counter >> 1) & 1;
        seg_f_available_tens = available_spaces_counter & 1;
        seg_a_available_units = (available_spaces_counter >> 5) & 1;
        seg_b_available_units = (available_spaces_counter >> 4) & 1;
        seg_c_available_units = (available_spaces_counter >> 3) & 1;
        seg_d_available_units = (available_spaces_counter >> 2) & 1;
        seg_e_available_units = (available_spaces_counter >> 1) & 1;
        seg_f_available_units = available_spaces_counter & 1;
        seg_a_count_tens = (count_car_counter >> 5) & 1;
        seg_b_count_tens = (count_car_counter >> 4) & 1;
        seg_c_count_tens = (count_car_counter >> 3) & 1;
        seg_d_count_tens = (count_car_counter >> 2) & 1;
        seg_e_count_tens = (count_car_counter >> 1) & 1;
        seg_f_count_tens = count_car_counter & 1;
        seg_a_count_units = (count_car_counter >> 5) & 1;
        seg_b_count_units = (count_car_counter >> 4) & 1;
        seg_c_count_units = (count_car_counter >> 3) & 1;
        seg_d_count_units = (count_car_counter >> 2) & 1;
        seg_e_count_units = (count_car_counter >> 1) & 1;
        seg_f_count_units = count_car_counter & 1;
    end
endmodule