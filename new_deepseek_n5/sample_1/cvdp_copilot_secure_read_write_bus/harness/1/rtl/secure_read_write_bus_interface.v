module secure_read_write_bus_interface (
    parameter p_configurable_key = 8'hAA,
    parameter p_data_width = 8,
    parameter p_addr_width = 8
);

    input i_addr,
           i_data_in,
           i_key_in,
           i_read_write_enable,
           i_capture_pulse,
           i_reset_bar,
    output o_data_out,
           o_error;

    // State variables
    reg state = 0; // 0: idle, 1: read, 2: write
    reg key_match = 1; // 1: match, 0: no match

    // Internal registers
    reg [p_addr_width-1:0] addr_reg;
    reg [p_data_width-1:0] data_reg;

    // Always block for state transitions
    always @ (posedge i_capture_pulse) begin
        if (i_reset_bar) begin
            // Reset all internal registers and outputs
            addr_reg = -1;
            data_reg = 0;
            o_data_out = 0;
            o_error = 0;
            state = 0;
            key_match = 1;
        end else begin
            case (state)
                0: // Idle state
                    if (i_read_write_enable) state = 1;
                    else state = 2;
                1: // Read operation
                    if (key_match) begin
                        o_data_out = data_reg;
                        o_error = 0;
                    end else begin
                        o_error = 1;
                        o_data_out = 0;
                    end
                    state = 0;
                2: // Write operation
                    if (key_match) begin
                        data_reg = i_data_in;
                        addr_reg = i_addr;
                        state = 0;
                    end else begin
                        o_error = 1;
                        o_data_out = 0;
                    end
            endcase
        end
    end

    // Always block for handling write operation
    always @ (posedge i_capture_pulse) begin
        if (i_read_write_enable) begin
            if (key_match) begin
                o_data_out = data_reg;
                o_error = 0;
            else begin
                o_error = 1;
                o_data_out = 0;
            end
            state = 0;
        end
    end

    // Always block for handling read operation
    always @ (posedge i_capture_pulse) begin
        if (!i_read_write_enable) begin
            if (key_match) begin
                o_data_out = data_reg;
                o_error = 0;
            else begin
                o_error = 1;
                o_data_out = 0;
            end
            state = 0;
        end
    end
endmodule