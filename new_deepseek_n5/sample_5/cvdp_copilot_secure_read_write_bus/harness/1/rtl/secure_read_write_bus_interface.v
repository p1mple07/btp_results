module secure_read_write_bus_interface (
    input i_addr,
    input i_data_in,
    input i_key_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_reset_bar,
    output o_data_out,
    output o_error
) 

    wire 
        ip [p_addr_width-1:0], 
        io [p_data_width-1:0];

    reg 
        ip_reg [p_addr_width-1:0], 
        io_reg [p_data_width-1:0],
        error_reg;

    parameter addr_width = p_addr_width;
    parameter data_width = p_data_width;

    always @ (posedge i_reset_bar) begin
        ip_reg = 0;
        io_reg = 0;
        error_reg = 1;
        o_error = 1;
    end

    always @ (posedge i_capture_pulse) begin
        if (i_key_in != p_configurable_key) begin
            error_reg = 1;
            io_reg = 0;
            o_error = 1;
        else begin
            if (i_read_write_enable == 1) begin
                ip_reg = i_addr;
            end else begin
                io_reg = i_data_in;
            end
            o_error = 0;
        end
    end

    o_data_out = io_reg;
    o_error = error_reg;

endmodule