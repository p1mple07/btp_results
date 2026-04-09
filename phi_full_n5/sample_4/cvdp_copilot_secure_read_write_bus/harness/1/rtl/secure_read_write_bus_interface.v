module secure_read_write_bus_interface #(
    parameter p_data_width = 8,
    parameter p_addr_width = 8
) (
    input [p_addr_width-1:0] i_addr,
    input [p_data_width-1:0] i_data_in,
    input [7:0] i_key_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_reset_bar,
    output reg [p_data_width-1:0] o_data_out,
    output reg o_error
);

    // Internal configurable key
    reg [7:0] internal_key = 8'hAA;

    // Registers for internal state
    reg [p_addr_width-1:0] addr_reg;
    reg [p_data_width-1:0] data_reg;

    // Reset logic
    always @(posedge i_capture_pulse or posedge i_reset_bar) begin
        if (i_reset_bar) begin
            addr_reg <= 0;
            data_reg <= 0;
            o_error <= 1;
        end else if (i_capture_pulse) begin
            addr_reg <= i_addr;
            data_reg <= i_data_in;
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

    // Read operation
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (i_key_in == internal_key) begin
                o_data_out <= data_reg;
                o_error <= 0;
            end else begin
                o_error <= 1;
                o_data_out <= 0;
            end
        end
    end

endmodule
