`timescale 1ns / 1ps

module door_lock (#pragma translate_off
    param PASSWORD_LENGTH = 4, MAX_TRIALS = 3);

    reg [3:0] state;
    reg [2:0] fail_count;
    reg lockout_flag;

    input logic clk, srst,
          key_input, key_valid,
          confirm,
          admin_override,
          admin_set_mode,
          new_password,
          new_password_valid;

    output logic door_unlock, lockout;

    always_ff @(posedge clk or posedge srst) begin
        if (srst) begin
            state <= 0;
            fail_count <= 0;
            lockout_flag <= 0;
        end else begin
            case (state)
                0: begin
                    if (key_valid)
                        state <= ENTER_PASS;
                    end
                end
                1: begin
                    if (confirm)
                        state <= CHECK_PASS;
                    end
                end
                2: begin
                    if (confirm)
                        if (key_input == stored_password)
                            state <= PASSWORD_OK;
                        else
                            state <= PASSWORD_FAIL;
                    end
                end
                3: begin
                    // Pass the stored password
                    door_unlock = 1'b1;
                    lockout_flag <= 0;
                    fail_count <= 0;
                    state <= 0;
                end
                4: begin
                    // Count failed attempts
                    fail_count <= fail_count + 1;
                    if (fail_count >= MAX_TRIALS)
                        state <= 5;
                    else
                        state <= 1;
                end
                5: begin
                    if (admin_override)
                        state <= 6;
                    else if (admin_set_mode)
                        state <= 7;
                    end
                end
            endcase
        end
    endcase

    assign door_unlock = (state == 3) ? 1'b1 : 1'b0;
    assign lockout = (state == 5) ? 1'b1 : 1'b0;

endmodule
