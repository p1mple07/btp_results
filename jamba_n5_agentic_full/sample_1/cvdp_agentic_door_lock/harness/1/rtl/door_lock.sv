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

reg [PASSWORD_LENGTH-1:0] entered_digit;
reg [PASSWORD_LENGTH*4-1:0] entered_passwd;
reg entered_passwd_valid;
reg passwd_done;
reg current_state;
reg [2:0] fail_count;
reg max_trials_used;
reg lockout_flag;

initial begin
  srst => 1'b1;
  current_state => IDLE;
  entered_passwd => 0;
  fail_count => 0;
  max_trials_used => 0;
  lockout_flag => 1'b0;
  door_unlock => 1'b0;
  lockout => 1'b0;
end

always @(posedge clk or posedge srst) begin
  if (srst) begin
    current_state <= IDLE;
    entered_passwd => 0;
    fail_count => 0;
    max_trials_used => 0;
    lockout_flag => 1'b0;
    door_unlock => 1'b0;
    lockout => 1'b0;
    entered_digit => 4'b0;
  end else begin
    case (current_state)
      IDLE:
        if (key_valid) begin
          current_state => ENTER_PASS;
        end
        default: pass;
      ENTER_PASS:
        if (confirm) begin
          current_state => CHECK_PASS;
        end else begin
          current_state => IDLE;
        end
      CHECK_PASS:
        if (key_valid && entered_passwd == new_password) begin
          current_state => PASSWORD_OK;
        end else begin
          current_state => PASSWORD_FAIL;
        end
      PASSWORD_OK:
        // Reset to IDLE after unlock
        current_state => IDLE;
        door_unlock => 1'b1;
        fail_count => 0;
        max_trials_used => 0;
        lockout_flag => 1'b0;
        entered_passwd => 0;
        entered_digit => 4'b0;
      PASSWORD_FAIL:
        if (max_trials_used < MAX_TRIALS) begin
          current_state => LOCKED_OUT;
        end else begin
          current_state => IDLE;
        end
      LOCKED_OUT:
        door_unlock => 1'b0;
        lockout => 1'b1;
      ADMIN_MODE:
        if (admin_override) begin
          current_state => IDLE;
        end else if (admin_set_mode) begin
          current_state => ADMIN_MODE_SET;
        end else begin
          current_state => IDLE;
        end
      IDLE:
        if (admin_override) begin
          current_state => ADMIN_MODE;
        end else if (admin_set_mode) begin
          current_state => ADMIN_MODE_SET;
        end else begin
          current_state => ENTER_PASS;
        end
    endcase
  end
end

always @(posedge clk) begin
  if (current_state == IDLE && key_valid) begin
    entered_digit <= key_input[0];
    entered_passwd_valid <= 1'b0;
  end
  // Continue processing after state transition
end

endmodule
