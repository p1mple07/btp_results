module secure_read_write_bus_interface (
    parameter p_data_width = 8,
    parameter p_addr_width = 8,
    parameter p_configurable_key = 8'hAA
);
    input i_addr,
    input i_data_in,
    input i_key_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_reset_bar,
    output o_data_out,
    output o_error
);
    // Internal registers
    reg [p_data_width-1:0] data_reg;
    reg [p_addr_width-1:0] addr_reg;
    reg o_error;

    // Always block triggered by capture_pulse
    always @ (i_capture_pulse) begin
        if (i_reset_bar) begin
            data_reg = 0;
            addr_reg = 0;
            o_error = 0;
            // Reset all data and error outputs
            o_data_out = 0;
        end else begin
            // Check if key matches
            if (i_key_in != p_configurable_key) begin
                o_error = 1;
            else begin
                // Perform read or write operation
                if (i_read_write_enable) begin
                    o_data_out = data_reg[i_addr];
                else begin
                    data_reg[i_addr] = i_data_in;
                end
                // Set error to 0 if access was granted
                o_error = 0;
            end
        end
    end
endmodule