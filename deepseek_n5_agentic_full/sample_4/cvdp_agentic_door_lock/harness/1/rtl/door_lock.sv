Module declaration
module door_lock #(parameter PASSWORD_LENGTH = 4, parameter MAX_TRIALS = 3) (
    input logicclk,
    input logic srst,
    input logic[key_input:3 downto 0],
    input logic[key_valid],
    input logic[1..0] confirm,
    input logic[1..0] admin_override,
    input logic[1..0] admin_set_mode,
    input logic[new_password:7 downto 0],
    input logic[new_password_valid],
    output logic door_unlock,
    output logic lockout
);

// State variables
reg state = 'IDLE;
reg entered_password = 0;
reg fail_count = 0;

// Always block
always @posedge(clk or srst) begin
    // Reset on synchronous reset
    if(srst)
        state = 'IDLE;
        entered_password = 0;
        fail_count = 0;
        door_unlock = 0;
        lockout = 0;
        return;
    end

    // State transitions
    case(state)
        'IDLE:
            if(key_valid && ((key_input & 8'b1111) != 0)) // Valid key press detected
                state = 'ENTER_PASS;
                
        'ENTER_PASS:
            // Check if all keys were pressed
            if(entering_password completed) // Implementation detail
                state = 'CHECK_PASS;
                
            // Handle partial key presses
            else if(key_valid) {
                entered_password = entered_password << 1;
                entered_password |= (key_input & 1);
                state = 'ENTER_PASS;
            }

        'CHECK_PASS:
            if(confirm) { // Password comparison
                if(entered_password == stored_password) {
                    // Success! Unlock the door
                    door_unlock = 1;
                    state = 'IDLE;
                } else {
                    // Failure occurred
                    fail_count = fail_count + 1;
                    state = 'FAILED;
                }
            }

        'FAILED:
            if(fail_count >= MAX_TRIALS) {
                // Max trials reached, lock out
                lockout = 1;
                state = 'LOCKED_OUT;
            } else {
                // Increment fail count again?
                fail_count = fail_count + 1;
                state = 'FAILED;
            }

        'LOCKED_OUT:
            if(admin_override) {
                // Override allowed
                door_unlock = 1;
                lockout = 0;
                state = 'IDLE;
            }

        'ADMIN_MODE:
            // Admin mode handling
            if(new_password_valid) {
                // Store new password
                stored_password = new_password;
                // Wait for user to enter new password
                state = 'IDLE;
            }

        default:
            state = 'IDLE;
    }
endcase

// Initial value assignments
initial begin
    $assign(stored_password = (1<<PASSWORD_LENGTH) + 1);
end

// End module
endmodule