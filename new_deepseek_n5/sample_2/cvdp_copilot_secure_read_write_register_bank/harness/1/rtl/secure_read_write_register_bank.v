module secure_read_write_register_bank(
    parameter p_address_width = 8,
    parameter p_data_width = 8,
    parameter p_unlock_code_0 = 0xAB,
    parameter p_unlock_code_1 = 0xCD
);

    // State variables
    reg state = 0; // 0: locked, 1: waiting for code0, 2: waiting for code1, 3: unlocked
    reg [p_address_width-1:0] address;

    // Unlock code storage
    reg [p_data_width-1:0] unlock_code_0 = p_unlock_code_0;
    reg [p_data_width-1:0] unlock_code_1 = p_unlock_code_1;

    // Inputs
    input [p_address_width-1:0] i_addr;
    input [p_data_width-1:0] i_data_in;
    input i_read_write_enable;
    input i_capture_pulse;
    input i_rst_n;

    // Outputs
    output [p_data_width-1:0] o_data_out;

    // State transitions
    always @(posedge i_capture_pulse) begin
        case (state)
            0: 
                // Check if write operation to address 0 or 1
                if (i_read_write_enable == 0) begin
                    if (i_addr == 0) begin
                        if (i_data_in == unlock_code_0) begin
                            state = 1;
                        end else begin
                            state = 0;
                        end
                    end else if (i_addr == 1) begin
                        if (i_data_in == unlock_code_1) begin
                            state = 1;
                        end else begin
                            state = 0;
                        end
                    end else begin
                        // Other addresses are locked
                        state = 0;
                    end
                end else begin
                    // Read operation
                    if (i_addr == 0 || i_addr == 1) begin
                        o_data_out = 0;
                    else begin
                        o_data_out = 0;
                    end
                end
            1: 
                // Waiting for code0
                if (i_read_write_enable == 0) begin
                    if (i_addr == 0) begin
                        if (i_data_in == unlock_code_0) begin
                            state = 2;
                        end else begin
                            state = 0;
                        end
                    end else begin
                        state = 0;
                    end
                end else begin
                    o_data_out = 0;
                end
            2: 
                // Waiting for code1
                if (i_read_write_enable == 0) begin
                    if (i_addr == 1) begin
                        if (i_data_in == unlock_code_1) begin
                            state = 3;
                        end else begin
                            state = 0;
                        end
                    end else begin
                        state = 0;
                    end
                end else begin
                    o_data_out = 0;
                end
            3: 
                // Unlocked
                o_data_out = i_data_in;
            default:
                state = 0;
        endcase
    end

    // Output data
    assign o_data_out = (state == 3) ? i_data_in : 0;

    // Reset handling
    always @* begin
        if (i_rst_n) begin
            state = 0;
            address = 0;
            unlock_code_0 = 0;
            unlock_code_1 = 0;
        end
    end

    // Encode address
    always @* begin
        address = i_addr;
    end

    // Encode data
    always @* begin
        if (state == 3) begin
            if (i_read_write_enable == 0) begin
                o_data_out = i_data_in;
            else begin
                o_data_out = 0;
            end
        else begin
            o_data_out = 0;
        end
    end
endmodule