module door_lock #(
    parameter PASSWORD_LENGTH = 4,
    parameter MAX_TRIALS = 3
)(
    input  logic clk,
    input  logic srst,
    input  logic [3:0] key_input,
    input  logic key_valid,
    input  logic confirm,
    input  logic admin_override,
    input  logic admin_set_mode,
    input  logic [PASSWORD_LENGTH*4-1:0] new_password,
    input  logic new_password_valid,
    output logic door_unlock,
    output logic lockout
);

reg [LOGIC] entered_digits;
reg [MAX_TRIALS-1:0] fail_count;
reg lockout_flag;
reg pending_admin;
reg [PASSWORD_LENGTH*4-1:0] new_pwd;
reg new_pw_valid;

always @(posedge clk or posedge srst) begin
    if (srst) begin
        entered_digits <= 0;
        fail_count <= 0;
        lockout_flag <= 0;
        new_pwd <= 0;
        new_pw_valid <= 0;
        door_unlock <= 0;
        lockout <= 0;
        entered_digits <= 0;
        entered_digits <= 0;
        entered_digits <= 0;
    end else begin
        if (key_valid) begin
            entered_digits <= entered_digits + 1;
        end

        if (confirm) begin
            if (key_input == new_password[KEY_INDEX]) begin
                state = PASSWORD_OK;
            end else begin
                state = PASSWORD_FAIL;
            end
        end else begin
            state = state;
        end
    end
end

always @(state or entered_digits) begin
    case (state)
        IDLE: begin
            if (key_valid) begin
                next_state = ENTER_PASS;
            end else begin
                next_state = IDLE;
            end
        end

        ENTER_PASS: begin
            if (confirm) begin
                if (key_input == new_password[KEY_INDEX]) begin
                    next_state = PASSWORD_OK;
                end else begin
                    next_state = PASSWORD_FAIL;
                end
            end else begin
                next_state = ENTER_PASS;
            end
        end

        PASSWORD_OK: begin
            if (admin_override) begin
                next_state = ADMIN_MODE;
            end else begin
                next_state = PASSWORD_OK;
            end
        end

        PASSWORD_FAIL: begin
            if (admin_override) begin
                next_state = ADMIN_MODE;
            end else begin
                next_state = LOCKED_OUT;
            end
        end

        LOCKED_OUT: begin
            if (admin_override) begin
                next_state = ADMIN_MODE;
                lockout_flag <= 0;
            end else begin
                next_state = LOCKED_OUT;
            end
        end

        ADMIN_MODE: begin
            if (admin_set_mode) begin
                next_state = IDLE;
            end else begin
                next_state = IDLE;
            end
        end
    end
end

// Outputs
assign door_unlock = (state == PASSWORD_OK) ? 1 : 0;
assign lockout = (state == LOCKED_OUT) ? 1 : 0;

endmodule
