module door_lock(
    parameter Password-Length = 4,
    parameter Max-Trials = 3
)(
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
)
{
    // Module internals
    reg [PASSWORD_LENGTH*4-1:0] entered_password;
    reg [PASSWORD_LENGTH*4-1:0] stored_password = {
        (1 << (PASSWORD_LENGTH*4 - 4)),
        0,
        0,
        0
    };

    // State variables
    reg current_state = IDLE;
    reg fail_count = 0;

    // FSM transitions
    always_comb begin
        case(current_state)
            IDLE:
                // Check if key_valid indicates a valid input
                if (key_valid && !admin_set_mode) begin
                    current_state = ENTER_PASS;
                end
                // If invalid, remain in IDLE
                else begin
                    // Reset entered_password and fail_count on invalid key
                    entered_password = 0;
                    fail_count = 0;
                end
            ENTER_PASS:
                // If confirm is asserted, process next key
                if (key_valid && confirm) begin
                    // Update entered_password with new key_input
                    entered_password = ((entere