module secure_read_write_bus_interface (
    parameter p_configurable_key = 8'hAA,
    parameter p_data_width = 8,
    parameter p_addr_width = 8
);
    input i_reset_bar,
    input i_capture_pulse,
    input i_read_write_enable,
    input i_addr,
    input i_key_in,
    input i_data_in,
    output o_data_out,
    output o_error
);

    reg key_reg = p_configurable_key;
    reg addr_reg;

    always @posedge i_capture_pulse begin
        if (i_reset_bar) begin
            key_reg = p_configurable_key;
            addr_reg = 0;
            o_error = 0;
            o_data_out = 0;
            return;
        end

        if (i_read_write_enable == 1) begin
            // Read operation
            if (key_reg == i_key_in) begin
                o_error = 0;
                o_data_out = i_addr;
            else begin
                o_error = 1;
                o_data_out = 0;
            end
        else begin
            // Write operation
            if (key_reg == i_key_in) begin
                o_error = 0;
                o_data_out = i_data_in;
            else begin
                o_error = 1;
                o_data_out = 0;
            end
        end
    end
endmodule