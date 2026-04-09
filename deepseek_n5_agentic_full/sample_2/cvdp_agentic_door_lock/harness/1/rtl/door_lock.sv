module door_lock #(integer PASSWORD_LENGTH = 4, integer MAX_TRIALS = 3)
    (
        input logic clk,
        input logic srst,
        input logic [3:0] key_input,
        input logic key_valid,
        input logic confirm,
        input logic admin_override,
        input logic admin_set_mode,
        input logic [PASSWORD_LENGTH*4-1:0] new_password,
        input logic new_password_valid,
        output logic door_unlock,
        output logic lockout
    );

    // State variables
    reg state = IDLE;
    reg entered_password = 0;
    reg fail_count = 0;

    // Initialize password on reset
    always @(posedgeclk) begin
        if (srst) begin
            state = IDLE;
            entered_password = 0;
            fail_count = 0;
        end
    end

    // Key buffer
    reg key_buffer [PASSWORD_LENGTH*4-1:0] = {4'b0};
    
    // FSM logic
    case(state)
        IDLE:
            if (key_valid && !admin_set_mode) begin
                state = ENTER_PASS;
            end
            // Else remain in IDLE

        ENTER_PASS:
            if (key_valid && admin_set_mode) begin
                state = CHECK_PASS;
            end
            else if (confirm) begin
                // After all key inputs, validate
                for (int i=0; i<PASSWORD_LENGTH; i=i+1) {
                    if (key_buffer[i] != (i < PASSWORD_LENGTH ? (i == (PASSWORD_LENGTH-1)) ? 1 : 0 : 0)) 
                        // Assuming right-aligned init
                    end
                }
                state = PASSWORD_OK;
            end
            // Else remain in ENTER_PASS

        CHECK_PASS:
            if (new_password_valid) begin
                // Assume new_password is loaded here
                if (entered_password == new_password) begin
                    state = IDLE;
                    door_unlock = 1;
                end else begin
                    fail_count = 0;
                    state = FAILED;
                end
            end
            // Else remain in CHECK_PASS

        FAILED:
            if (admin_override || (admin_set_mode && admin_override)) begin
                state = IDLE;
                door_unlock = 1;
            end else if (fail_count + 1 >= MAX_TRIALS) begin
                state = LOCKED_OUT;
                lockout = 1;
            end else begin
                fail_count = fail_count + 1;
                state = FAILED;
            end

        LOCKED_OUT:
            if (admin_override) begin
                state = IDLE;
                lockout = 0;
            end else if (!admin_set_mode) begin
                wait for 2 clock cycles
                state = IDLE;
                lockout = 0;
            end else begin
                // Invalid state
                state = IDLE;
            end

        ADMIN_MODE:
            if (admin_set_mode) begin
                // Accept new password
                // Assume new_password is loaded here
                entered_password = new_password;
                state = IDLE;
            end else begin
                // No action, wait for new_password_valid
            end

    endcase

endmodule