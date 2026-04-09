module secure_read_write_bus_interface #(
    parameter p_data_width = 8,
    parameter p_addr_width = 8,
    parameter p_configurable_key = 8'hAA
)(
    input wire i_addr,
    input wire i_data_in,
    input wire i_key_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_reset_bar,
    output reg o_data_out,
    output reg o_error
);

    // Internal registers
    reg [p_data_width-1:0] data_reg;
    reg [p_addr_width-1:0] address_reg;
    reg internal_key = p_configurable_key;

    // Reset condition
    always @(posedge i_capture_pulse or posedge i_reset_bar) begin
        if (i_reset_bar) begin
            o_data_out <= 0;
            o_error <= 1;
            data_reg <= 0;
            address_reg <= 0;
        end else if (i_capture_pulse) begin
            address_reg <= i_addr;
            data_reg <= i_data_in;
        end
    end

    // Read operation
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (i_key_in == internal_key) begin
                o_data_out <= data_reg;
                o_error <= 0;
            end else begin
                o_data_out <= 0;
                o_error <= 1;
            end
        end
    end

    // Write operation
    always @(posedge i_capture_pulse) begin
        if (!i_read_write_enable) begin
            if (i_key_in == internal_key) begin
                data_reg <= i_data_in;
                o_error <= 0;
            end else begin
                o_error <= 1;
                o_data_out <= 0;
            end
        end
    end

endmodule
