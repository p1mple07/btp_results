module door_lock #(
    parameter int PASSWORD_LENGTH = 4,
    parameter int MAX_TRIALS = 3
) (
    input logic rst, clk,
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

    // Define the module's internal signals and variables here.

// Define the FSM here.

// Define the state transition logic here.

// Define the user authentication flow here.

// Define the password flow here.

// Define the administrative mode functionality here.

endmodule