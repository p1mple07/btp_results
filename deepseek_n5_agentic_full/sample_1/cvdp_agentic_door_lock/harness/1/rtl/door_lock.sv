module door_lock #(
    parameter PASSWORD_LENGTH = 4,
    parameter MAX_TRIALS = 3
)(
    input logic_clk,
    input logic srst,
    input logic[3:0] key_input,
    input logic key_valid,
    input logic confirm,
    input logic admin_override,
    input logic admin_set_mode,
    input logic[PASSWORD_LENGTH*4-1:0] new_password,
    input logic new_password_valid,
    output logic door_unlock,
    output logic lockout
);

// State variables
reg state = IDLE;
reg entered_password = 0;
reg current_digit = 0;
reg fail_count = 0;

// State machine transitions
always_comb begin
    // Initial state
    if (state == IDLE)
    begin
        if (admin_override && admin_set_mode)
            state = ADMIN_MODE;
        else if (key_valid)
            state = ENTER_PASS;
    end

    // During password entry
    elseif (state == ENTER_PASS)
    begin
        if (!key_valid || !key_input) // Invalid input
            state = IDLE;
        else if (current_digit < PASSWORD_LENGTH)
            current_digit = key_input;
            state = ENTER_PASS;
        else if (current_digit == PASSWORD_LENGTH)
            state = CHECK_PASS;
        end
    end

    // During password checking
    elseif (state == CHECK_PASS)
    begin
        if (new_password_valid && new_password[0:(PASSWORD_LENGTH-1)] == entered_password)
            state = IDLE;
        else
            fail_count++;
            if (fail_count >= MAX TRIALS)
                state = LOCKED_OUT;
        end
    end

    // After failed attempts
    elseif (state == PASSWORD_FAIL)
    begin
        if (admin_override)
            state = IDLE;
        else
            if (fail_count + 1 >= MAX_TRIALS)
                state = LOCKED_OUT;
            else
                state = IDLE;
        end
    end

    // During lockout
    elseif (state == LOCKED_OUT)
        if (admin_override)
            state = IDLE;
            door_unlock = 1;
        else
            lockout = 1;
            state = IDLE;
        end

    // In admin mode
    elseif (state == ADMIN_MODE)
        if (new_password_valid)
            entered_password = new_password;
            state = IDLE;
        else
            state = ENTER_PASS;
        end
    end
end

// Output assertions
output logic initial_state = state;
output logic entered_password = entered_password;
output logic current_digit = current_digit;
output logic fail_count = fail_count;
output logic lockout = lockout;
output logic door_unlock = door_unlock;

endmodule