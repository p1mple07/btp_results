module door_lock #(
    parameter PASSWORD_LENGTH = 4,
    parameter MAX_TRIALS = 3
)(
    input  logic                         clk,
    input  logic                         srst, 
    input  logic [3:0]                   key_input,
    input  logic                         key_valid,
    input  logic                         confirm,
    input  logic                         admin_override,
    input  logic                         admin_set_mode,
    input  logic [PASSWORD_LENGTH*4-1:0] new_password,
    input  logic                         new_password_valid,
    output logic                         door_unlock,
    output logic                         lockout
);
