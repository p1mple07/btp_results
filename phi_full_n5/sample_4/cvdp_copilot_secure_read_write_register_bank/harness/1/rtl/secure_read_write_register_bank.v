module secure_read_write_register_bank #(
    parameter p_addr_width = 8,
    parameter p_data_width = 8,
    parameter p_unlock_code_0 = 0xAB,
    parameter p_unlock_code_1 = 0xCD
) (
    input [p_addr_width-1:0] i_addr,
    input [p_data_width-1:0] i_data_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_rst_n,
    output reg [p_data_width-1:0] o_data_out
);

    // Unlock status
    reg [p_addr_width-1:0] unlock_status;

    // Unlock control logic
    always @(posedge i_capture_pulse or i_rst_n) begin
        if (!i_rst_n) begin
            unlock_status <= 0; // Reset unlock status on reset
        end else if (i_read_write_enable == 0) begin
            if (i_addr == 0) begin
                unlock_status <= unlock_status | (p_unlock_code_0 == i_data_in);
            end else if (i_addr == 1) begin
                unlock_status <= unlock_status | (p_unlock_code_1 == i_data_in);
            end
        end
    end

    // Register bank contents
    reg [p_data_width-1:0] register_bank [p_addr_width-1:0];

    // Initialization on reset
    initial begin
        if (!i_rst_n) begin
            for (int i = 0; i < p_addr_width; i++) begin
                register_bank[i] = 0;
            end
        end
    end

    // Unlocking mechanism
    always @(i_addr or i_data_in or i_read_write_enable) begin
        if (i_read_write_enable == 0) begin
            if (unlock_status[0] && unlock_status[1]) begin
                register_bank[i_addr] <= i_data_in;
                o_data_out = 0; // Default output on write operation
            end else begin
                o_data_out = 0; // Default output on write operation
            end
        end else if (i_read_write_enable == 1) begin
            if (unlock_status[0] && unlock_status[1]) begin
                o_data_out = register_bank[i_addr];
            end else begin
                o_data_out = 0; // Default output on read operation
            end
        end
    end

endmodule
