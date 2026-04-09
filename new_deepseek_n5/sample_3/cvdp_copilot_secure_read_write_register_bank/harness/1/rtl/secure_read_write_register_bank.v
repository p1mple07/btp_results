module secure_read_write_register_bank(
    parameter p_address_width = 8,
    parameter p_data_width = 8,
    parameter p_unlock_code_0 = 0xAB,
    parameter p_unlock_code_1 = 0xCD
);

    // State machine states
    enum state_state = {
        UNLOCKED,
        UNLOCKING,
        LOCKED
    };

    // State register
    reg state_state state = UNLOCKED;

    // Address generator
    reg [p_address_width-1:0] addr;

    // Unlock codes
    reg [p_data_width-1:0] unlock_code_0, unlock_code_1;

    // Internal buffers
    reg [p_data_width-1:0] buffer;

    always_comb input_valid_addr = (state == UNLOCKED) ? (addr >= 0 && addr <= (1 << p_address_width) - 1) : 1;

    always_comb input_valid_write = (state == UNLOCKED && (addr == 0 || addr == 1)) || (state == UNLOCKING);

    always_comb input_valid_read = (state == UNLOCKED && addr != 0 && addr != 1);

    // Address increment
    always addr = addr + 1;

    // Unlock sequence
    always edge capture_pulse begin
        if (i_rst_n == 0) begin
            state = UNLOCKED;
        end

        if (state == UNLOCKED) begin
            if (i_read_write_enable == 0) begin
                if (addr == 0) begin
                    unlock_code_0 = p_unlock_code_0;
                end else if (addr == 1) begin
                    unlock_code_1 = p_unlock_code_1;
                end
            end
        end else if (state == UNLOCKING) begin
            if (addr == 0 && addr == 1) begin
                state = UNLOCKED;
            end
        end else if (state == LOCKED) begin
            addr = 0;
        end
    end

    // Write operation
    always edge capture_pulse begin
        if (i_read_write_enable == 0 && addr == 0 && addr == 1 && state == UNLOCKED) begin
            buffer = i_data_in;
        end
    end

    // Read operation
    always edge capture_pulse begin
        if (i_read_write_enable == 1 && addr != 0 && addr != 1 && state == UNLOCKED) begin
            o_data_out = buffer;
        end
    end

    // Output data
    always_comb o_data_out = (state == UNLOCKED && (addr == 0 || addr == 1)) ? buffer : 0;

    // Reset
    always_comb reset_all = i_rst_n;

    endmodule