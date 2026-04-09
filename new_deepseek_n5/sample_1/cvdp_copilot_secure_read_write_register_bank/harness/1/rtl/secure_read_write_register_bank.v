module secure_read_write_register_bank(
    parameter p_address_width,
    parameter p_data_width,
    parameter p_unlock_code_0,
    parameter p_unlock_code_1,
    input i_addr,
    input i_data_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_rst_n,
    output o_data_out
);

    // State variables
    parameter state = 0;
    parameter waiting_for_code0 = 1;
    parameter waiting_for_code1 = 2;

    // State encoding
    enum state_state {
        unlocked,
        waiting_for_code0,
        waiting_for_code1
    };

    // State transition table
    reg state_state state_reg;
    always next_state() begin
        case (state, i_read_write_enable, i_capture_pulse)
            // Initial state
            0, 0, 0: state_reg = unlocked;
            0, 0, 1: state_reg = waiting_for_code0;
            0, 1, 0: state_reg = waiting_for_code0;
            0, 1, 1: state_reg = waiting_for_code1;
            default: state_reg = unlocked;
        endcase
    end

    // Register file
    reg [p_data_width - 1:0] registers[(2 << p_address_width) + 1];

    // Unlock code verification
    reg [p_data_width - 1:0] code0_reg, code1_reg;
    always code0_reg = i_data_in;
    always code1_reg = i_data_in;

    // Address calculation
    reg [p_address_width - 1:0] addr0, addr1;
    assign addr0 = (state == waiting_for_code0) ? i_addr : (state == unlocked ? 0 : 1);
    assign addr1 = (state == waiting_for_code1) ? i_addr : (state == unlocked ? 0 : 1);

    // Code verification logic
    always @ (i_capture_pulseposededge) begin
        if (i_rst_n) begin
            state_reg = unlocked;
            code0_reg = p_unlock_code_0;
            code1_reg = p_unlock_code_1;
        end else if (state_reg == unlocked) begin
            // Code0 verification
            if (addr0 == 0 && code0_reg == p_unlock_code_0) begin
                state_reg = waiting_for_code1;
                code1_reg = p_unlock_code_1;
            end
            // Code1 verification
            else if (addr1 == 1 && code1_reg == p_unlock_code_1) begin
                state_reg = unlocked;
            end
            // Other cases
            else state_reg = unlocked;
        end
    end

    // Read operation
    always @ (i_capture_pulseposededge) begin
        if (i_read_write_enable == 1 && state_reg == unlocked && addr0 == 0) begin
            o_data_out = registers[0];
        else if (i_read_write_enable == 1 && state_reg == unlocked && addr0 == 1) begin
            o_data_out = registers[1];
        else begin
            o_data_out = 0;
        end
    end

    // Write operation
    always @ (i_capture_pulseposededge) begin
        if (i_read_write_enable == 0 && state_reg == unlocked) begin
            if (addr0 == 0 || addr0 == 1) begin
                registers[addr0] = i_data_in;
            else begin
                o_data_out = 0;
            end
        else begin
            o_data_out = 0;
        end
    end

endmodule