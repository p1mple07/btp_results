module secure_read_write_register_bank #(
    parameter p_addr_width = 8,
    parameter p_data_width = 8,
    parameter p_unlock_code_0 = 0xAB,
    parameter p_unlock_code_1 = 0xCD
) (
    input wire [p_addr_width-1:0] i_addr,
    input wire [p_data_width-1:0] i_data_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_rst_n,
    output reg [p_data_width-1:0] o_data_out
);

    // Unlock state machine
    reg [p_data_width-1:0] unlock_status;

    // Unlock sequence state logic
    always @(posedge i_capture_pulse or i_rst_n) begin
        if (!i_rst_n) begin
            unlock_status <= 0; // Reset unlock status
        end else if (i_addr == 0 && i_data_in == p_unlock_code_0) begin
            unlock_status <= 1; // Unlock status for address 0
        end else if (i_addr == 1 && i_data_in == p_unlock_code_1) begin
            unlock_status <= 2; // Unlock status for address 1
        end else if (unlock_status == 2) begin
            unlock_status <= 3; // Proceed to the next unlock step
        end
    end

    // Write operation logic
    always @(posedge i_capture_pulse or i_rst_n) begin
        if (!i_rst_n) begin
            o_data_out <= 0; // Default output for write operations
        end else if (i_read_write_enable == 0) begin
            if (unlock_status == 3) begin // Check unlock status
                o_data_out <= i_data_in; // Perform write operation
            end else begin
                o_data_out <= 0; // Default output, register is locked
            end
        end
    end

    // Read operation logic
    always @(posedge i_capture_pulse or i_rst_n) begin
        if (!i_rst_n) begin
            o_data_out <= 0; // Default output for read operations
        end else if (i_read_write_enable == 1) begin
            if (unlock_status >= 3) begin // Check unlock status
                o_data_out <= i_data_in; // Perform read operation
            end else begin
                o_data_out <= 0; // Default output, register is locked
            end
        end
    end

    // Restricted access logic
    always @(posedge i_capture_pulse or i_rst_n) begin
        if (i_addr == 0 || i_addr == 1) begin
            o_data_out <= 0; // Addresses 0 and 1 are write-only
        end else begin
            if (unlock_status < 3) begin
                o_data_out <= 0; // Other addresses are inaccessible
            end
        end
    end

endmodule
