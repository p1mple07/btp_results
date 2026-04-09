module secure_read_write_bus_interface #(
    parameter p_data_width = 8,
    parameter p_addr_width = 8,
    parameter p_configurable_key = 8'hAA
) (
    input wire [p_addr_width-1:0] i_addr,
    input wire i_capture_pulse,
    input wire i_read_write_enable,
    input wire i_key_in,
    input wire i_reset_bar,
    output reg [p_data_width-1:0] o_data_out,
    output reg o_error
);

    // Internal registers
    reg [p_data_width-1:0] internal_data;
    reg [7:0] internal_key;

    // Reset condition
    always @(posedge i_capture_pulse or posedge i_reset_bar) begin
        if (i_reset_bar == 1'b0) begin
            internal_data <= 0;
            internal_key <= p_configurable_key;
            o_data_out <= 0;
            o_error <= 1'b0;
        end
    end

    // Comparison of input key with internal key
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (internal_key == i_key_in) begin
                o_data_out <= internal_data;
                o_error <= 1'b0;
            end else begin
                o_data_out <= 0;
                o_error <= 1'b1;
            end
        end
    end

    // Write operation
    always @(posedge i_capture_pulse) begin
        if (!i_read_write_enable) begin
            if (internal_key == i_key_in) begin
                internal_data <= i_data_in;
            end else begin
                o_error <= 1'b1;
                o_data_out <= 0;
            end
        end
    end

    // Read operation
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (internal_key == i_key_in) begin
                o_data_out <= internal_data;
                o_error <= 1'b0;
            end else begin
                o_data_out <= 0;
                o_error <= 1'b1;
            end
        end
    end

endmodule
