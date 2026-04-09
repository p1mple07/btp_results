module secure_read_write_register_bank(
    input wire [p_address_width-1:0] i_addr,
    input wire [p_data_width-1:0] i_data_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_rst_n,
    output wire [p_data_width-1:0] o_data_out
);

    // State variables
    reg state = 0;
    reg [p_address_width-1:0] addr = 0;
    reg [p_data_width-1:0] data = 0;

    // Unlock codes
    literal unlock_code_0 = p_unlock_code_0;
    literal unlock_code_1 = p_unlock_code_1;

    // Register array
    reg [p_address_width-1:0] registers = 0;

    // State machine
    always @(posedge i_capture_pulse) begin
        case (state)
            0:
                if (i_read_write_enable == 1 && addr == 0) begin
                    if (i_data_in == unlock_code_0) begin
                        addr = 1;
                        state = 1;
                    else begin
                        // Reset
                        state = 3;
                        addr = 0;
                        registers = 0;
                    end
                end else if (i_read_write_enable == 0 && addr == 0) begin
                    // Write to address 0
                    data = i_data_in;
                    addr = 1;
                end else if (i_read_write_enable == 1 && addr == 1) begin
                    if (i_data_in == unlock_code_1) begin
                        // Unlock complete
                        state = 2;
                        addr = 0;
                    else begin
                        // Reset
                        state = 3;
                        addr = 0;
                        registers = 0;
                    end
                end else if (i_rst_n) begin
                    // Reset
                    state = 3;
                    addr = 0;
                    registers = 0;
                end
            1:
                if (i_read_write_enable == 1 && addr == 1) begin
                    if (i_data_in == unlock_code_1) begin
                        // Unlock complete
                        state = 2;
                        addr = 0;
                    else begin
                        // Reset
                        state = 3;
                        addr = 0;
                        registers = 0;
                    end
                end else if (i_rst_n) begin
                    // Reset
                    state = 3;
                    addr = 0;
                    registers = 0;
                end
            2:
                // Unlock complete, allow read/write
                o_data_out = registers[addr];
            3:
                // Error state, output 0
                o_data_out = 0;
        endcase
    end

    // Register array implementation
    always @* begin
        registers[addr] = i_data_in;
    end

endmodule