module secure_read_write_bus_interface(
    input p_addr_width bit i_addr,
    input p_data_width bit i_data_in,
    input i_key_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_reset_bar
);

reg [31:0] internal_key;
reg [31:0] data_out;
bit o_error;

always @(posedge i_capture_pulse) begin
    if (i_reset_bar) begin
        internal_key <= 32'h0;
        data_out <= 32'h0;
        o_error <= 1'b1;
        o_data_out <= 0;
    end else begin
        if (i_read_write_enable == 1) begin
            if (i_key_in == internal_key) begin
                data_out <= i_data_in;
                o_error <= 1'b0;
            end else begin
                o_error <= 1'b1;
                data_out <= 0;
            end
        end else begin
            o_error <= 1'b1;
            data_out <= 0;
        end
    end
end

assign o_data_out = (i_read_write_enable == 1 && i_key_in == internal_key) ? i_data_in : 32'h0;

always @(*) begin
    assign internal_key = p_configurable_key;
    assign data_out = o_data_out;
    assign o_error = o_error;
end

endmodule
