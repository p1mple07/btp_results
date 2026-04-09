module secure_read_write_bus_interface #(
    parameter p_data_width = 8,
    parameter p_addr_width = 8,
    parameter p_configurable_key = 8'hAA
) (
    input wire i_capture_pulse,
    input wire i_reset_bar,
    input wire [p_addr_width-1:0] i_addr,
    input wire [p_data_width-1:0] i_data_in,
    input wire i_key_in,
    input wire i_read_write_enable,
    output reg o_data_out,
    output reg o_error
);

    reg [p_data_width-1:0] temp_data_out;
    reg temp_error;

    // Internal state register
    reg [p_addr_width-1:0] temp_addr;
    reg temp_key;

    // Default values
    always @(posedge i_capture_pulse or posedge i_reset_bar) begin
        if (i_reset_bar) begin
            o_data_out <= 0;
            o_error <= 0;
            temp_data_out <= 0;
            temp_error <= 0;
            temp_addr <= 0;
            temp_key <= p_configurable_key;
        end else begin
            if (i_read_write_enable) begin
                temp_addr <= i_addr;
                temp_key <= i_key_in;
            end
        end
    end

    // Authorization check
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (temp_key == p_configurable_key) begin
                temp_data_out <= i_data_in;
                o_error <= 0;
            end else begin
                temp_data_out <= 0;
                o_error <= 1;
            end
        end else begin
            temp_data_out <= 0;
            o_error <= 0;
        end
    end

    // Output assignment
    assign o_data_out = temp_data_out;
    assign o_error = temp_error;

endmodule
