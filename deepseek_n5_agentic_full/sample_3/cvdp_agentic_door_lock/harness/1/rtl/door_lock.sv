Module declaration
module door_lock #(parameter PASSWORD_LENGTH = 4, parameter MAX_TRIALS = 3) (
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

// Variables
reg logic entered_password;
reg logic fail_count = 0;

// State Machine
state [
    IDLE,
    ENTER_PASS,
    CHECK_PASS,
    PASSWORD_OK,
    PASSWORD_FAIL,
    LOCKED_OUT,
    ADMIN_MODE
] fsm = IDLE;

always_ff @(posedge clk or posedge srst) begin
    if (srst) begin
        // Reset state to IDLE with no entered password
        fsm = IDLE;
        entered_password = 0;
        fail_count = 0;
    end else begin
        // Current state processing
        case(fsm)
        // IDLE state
            when IDLE
                if (key_valid && key_input[0]) begin
                    fsm = ENTER_PASS;
                end
            // ENTER_PASS state
            when ENTER_PASS
                if (key_valid && (key_input == entered_password)) begin
                    fsm = CHECK_PASS;
                end else if (key_valid) begin
                    // Invalid key, move to FAILED state
                    fail_count +== 1;
                    if (fail_count >= MAX_TRIALS) begin
                        fsm = LOCKED_OUT;
                    end
                end
            // CHECK_PASS state
            when CHECK_PASS
                if (confirm && ((int(entered_password) == int(new_password))) && (new_password_valid)) begin
                    // Password accepted
                    door_unlock = 1;
                    lockout = 0;
                    fsm = IDLE;
                else if (!admin_set_mode) begin
                    // Maximum trials reached, stay locked
                    lockout = 1;
                    fsm = LOCKED_OUT;
                end
            // FAILED state
            when FAILED
                if (admin_override || admin_set_mode) begin
                    fsm = ADMIN_MODE;
                end else if (new_password_valid) begin
                    // Transition to ADMIN state upon successful overwrite
                    fsm = ADMIN_MODE;
                end
            // Other states
            default
                fsm = fsm;
        end
        // Handle transitions to IDLE when exiting failed states
        case(fsm)
        when IDLE
            // No action needed, already in IDLE
        when ENTER_PASS
            // Already handled above
        when CHECK_PASS
            // Already handled above
        when PASSWORD_OK
            // Already handled above
        when FAILED
            // Already handled above
        when LOCKED_OUT
            // Already handled above
        when ADMIN_MODE
            // Already handled above
        default
            // No action needed
        endcase
    end
end

// Final state assignments
always begin
    // Ensure final states are assigned
    case(fsm)
    when IDLE
        // No action needed, already handled above
    when ENTER_PASS
        // Already handled above
    when CHECK_PASS
        // Already handled above
    when PASSWORD_OK
        // Already handled above
    when FAILED
        // Already handled above
    when LOCKED_OUT
        // Already handled above
    when ADMIN_MODE
        // Already handled above
    default
        // No action needed
    endcase
end

endmodule