module secure_read_write_bus_interface (
    input wire i_addr,
    input wire i_data_in,
    input wire i_key_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_reset_bar
);

    localparam p_configurable_key = 8'b10101010; // 0xAA
    localparam p_data_width = 8;
    localparam p_addr_width = 8;

    reg [PADWIDTH-1:0] addr;
    reg [PADWIDTH-1:0] data;
    wire o_error;
    wire o_data_out;

    always @(posedge i_capture_pulse or negedge i_reset_bar) begin
        if (i_reset_bar) begin
            o_error <= 1;
            o_data_out <= 0;
            addr <= 0;
            data <= 0;
        end else begin
            if (i_read_write_enable) begin
                if (i_key_in == p_configurable_key) begin
                    o_data_out = i_data_in;
                    o_error = 0;
                end else begin
                    o_data_out = 0;
                    o_error = 1;
                end
            end else begin
                o_data_out = 0;
                o_error = 0;
            end
        end
    end

endmodule
