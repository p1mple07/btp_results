module secure_read_write_bus_interface #(
    parameter int p_configurable_key = 8'hAA,
    parameter int p_data_width = 8,
    parameter int p_addr_width = 8
) (
    input wire i_addr,
    input wire i_data_in,
    input wire i_key_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_reset_bar
);

reg [31:0] data; // assuming data width 32? But we can use generic.
reg [7:0] addr;
reg key_match;
reg o_data_out;
reg o_error;

always @(posedge i_capture_pulse) begin
    if (i_reset_bar) begin
        // reset all
        o_data_out <= 0;
        o_error <= 0;
        data <= 0;
        addr <= 0;
        key_match <= 0;
    end else begin
        if (i_read_write_enable == 1) begin
            if (i_key_in == p_configurable_key) begin
                o_data_out <= i_data_in;
                o_error <= 0;
            else
                o_error <= 1;
                o_data_out <= 0;
            end
        end else begin
            o_data_out <= 0;
            o_error <= 0;
        end
    end
end

assign o_data_out = o_data_out ? i_data_in : 0;

assign o_error = o_error ? 1 : 0;

endmodule
