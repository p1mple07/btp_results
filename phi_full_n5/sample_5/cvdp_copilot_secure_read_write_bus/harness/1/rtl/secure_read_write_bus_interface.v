module secure_read_write_bus_interface #(
    parameter p_data_width = 8,
    parameter p_addr_width = 8,
    parameter p_configurable_key = 8'hAA
) (
    input wire [p_addr_width-1:0] i_addr,
    input wire [p_data_width-1:0] i_data_in,
    input wire [7:0] i_key_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_reset_bar,
    output reg o_data_out,
    output reg o_error
);

    // Internal configurable key
    reg [7:0] internal_key = p_configurable_key;

    // Reset synchronous assignment
    always @(posedge i_capture_pulse) begin
        if (i_reset_bar) begin
            o_data_out <= 0;
            o_error <= 1;
            internal_key <= p_configurable_key; // Reset internal key
        end else begin
            if (i_read_write_enable) begin
                // Read operation
                o_data_out <= 0;
                o_error <= 1;
            end else begin
                // Write operation
                if (i_key_in == internal_key) begin
                    o_data_out <= i_data_in;
                    o_error <= 0;
                end else begin
                    o_data_out <= 0;
                    o_error <= 1;
                end
            end
        end
    end

endmodule
