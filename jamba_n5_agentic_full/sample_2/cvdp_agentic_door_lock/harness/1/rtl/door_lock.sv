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

// State machine
localparam ENTER_PASS = 2';
localparam CHECK_PASS = 3';
localparam PASSWORD_OK = 4';
localparam PASSWORD_FAIL = 5';
localparam LOCKED_OUT = 6';
localparam ADMIN_MODE = 7';

reg [2:0] state;
reg enter_pass_flag;
reg check_pass_flag;
reg password_ok_flag;
reg password_fail_flag;
reg locked_out_flag;
reg admin_mode_flag;

always_ff @(posedge clk or posedge srst) begin
    if (srst) begin
        state <= ENTER_PASS;
        enter_pass_flag <= 1'b1;
        check_pass_flag <= 1'b0;
        password_ok_flag <= 1'b0;
        password_fail_flag <= 1'b0;
        locked_out_flag <= 1'b0;
        admin_mode_flag <= 1'b0;
        door_unlock <= 1'b0;
        lockout <= 1'b0;
        fail_count <= 0;
    end else begin
        case (state)
            ENTER_PASS: begin
                if (key_valid) begin
                    enter_pass_flag <= 1'b0;
                    state <= CHECK_PASS;
                end else begin
                    state <= ENTER_PASS;
                end
            end

            CHECK_PASS: begin
                if (confirm) begin
                    if (key_input == new_password) begin
                        // correct
                        pass_flag <= 1'b1;
                        state <= PASSWORD_OK;
                    end else begin
                        // incorrect
                        pass_flag <= 1'b0;
                        state <= PASSWORD_FAIL;
                    end
                end
            end

            PASSWORD_OK: begin
                if (admin_override) begin
                    state <= ADMIN_MODE;
                    admin_mode_flag <= 1'b1;
                    lockout <= 1'b0;
                end else begin
                    state <= IDLE;
                end
            end

            PASSWORD_FAIL: begin
                if (admin_set_mode) begin
                    state <= ADMIN_MODE;
                    admin_mode_flag <= 1'b1;
                end else begin
                    // do nothing? maybe just stay in PASSWORD_FAIL?
                    state <= PASSWORD_FAIL;
                end
            end

            LOCKED_OUT: begin
                door_unlock <= 1'b0;
                lockout <= 1'b1;
                fail_count <= max_trials;
            end

            ADMIN_MODE: begin
                if (admin_set_mode) begin
                    state <= IDLE;
                    fail_count <= 0;
                end
            end

            default: state <= IDLE;
        endcase
    end
endelse

assign door_unlock = (state == PASSWORD_OK) && (pass_flag);
assign lockout = (state == LOCKED_OUT);

endmodule
