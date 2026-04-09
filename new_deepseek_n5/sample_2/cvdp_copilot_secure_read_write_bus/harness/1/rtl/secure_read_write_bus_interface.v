parameter p_configurable_key = 8'hAA;
parameter p_data_width = 8;
parameter p_addr_width = 8;

module secure_read_write_bus_interface(
    input wire p_addr_width i_addr,
    input wire p_data_width i_data_in,
    input wire 8 i_key_in,
    input wire 1 i_read_write_enable,
    input wire 1 i_capture_pulse,
    input wire 1 i_reset_bar,
    output wire p_data_width o_data_out,
    output wire 1 o_error
) {
    wire reg [p_addr_width-1:0] addr;
    wire reg [p_data_width-1:0] data;
    reg [1] state = 0; // 0: idle, 1: read, 2: write
    reg [1] is_error = 0;
    
    always @posedge i_capture_pulse begin
        if (i_reset_bar) begin
            state = 0;
            o_error = 0;
            o_data_out = 0;
            addr = 0;
            data = 0;
            continue;
        end
        
        if (i_read_write_enable) begin
            state = 1;
        end else begin
            state = 2;
        end
        
        if (state == 1) begin // Read operation
            if (i_key_in != p_configurable_key) begin
                o_error = 1;
                o_data_out = 0;
                addr = 0;
                data = 0;
                continue;
            end
            if (i_addr >= 0 && i_addr < (1 << p_addr_width)) begin
                addr = i_addr;
                data = i_data_in;
            else begin
                o_error = 1;
                o_data_out = 0;
                continue;
            end
        end else if (state == 2) begin // Write operation
            if (i_key_in != p_configurable_key) begin
                o_error = 1;
                o_data_out = 0;
                addr = 0;
                data = 0;
                continue;
            end
            if (i_addr >= 0 && i_addr < (1 << p_addr_width)) begin
                data = i_data_in;
                addr = i_addr;
            else begin
                o_error = 1;
                o_data_out = 0;
                continue;
            end
        end
        
        o_data_out = data;
        o_error = is_error;
    end
}