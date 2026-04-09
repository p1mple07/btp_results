module secure_read_write_register_bank #(
    parameter p_addr_width = 8,
    parameter p_data_width = 8,
    parameter p_unlock_code_0 = 0xAB,
    parameter p_unlock_code_1 = 0xCD
) (
    input [p_addr_width-1:0] i_addr,
    input [p_data_width-1:0] i_data_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_rst_n,
    output reg [p_data_width-1:0] o_data_out
);

    // Unlock control
    reg [p_data_width-1:0] unlock_status;
    reg [p_addr_width-1:0] address_register [0:2];

    // Unlock sequence
    always @(posedge i_capture_pulse) begin
        if (!i_rst_n) begin
            unlock_status <= 0;
            address_register[0] <= 0;
            address_register[1] <= 0;
        end else if (i_read_write_enable == 0) begin
            if (address_register[0] != p_unlock_code_0) begin
                unlock_status <= 0;
                address_register[0] <= 0;
            end else if (address_register[1] != p_unlock_code_1) begin
                unlock_status <= 0;
                address_register[1] <= 0;
            end else begin
                unlock_status <= 1;
                address_register[2] <= i_data_in;
            end
        end else begin
            unlock_status <= unlock_status;
        end
    end

    // Read operation
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable == 1 && unlock_status) begin
            o_data_out <= address_register[i_addr];
        end else if (i_read_write_enable == 1 && !unlock_status) begin
            o_data_out <= 0;
        end
    end

    // Write operation
    always @(posedge i_capture_pulse) begin
        if (i_read_write_enable == 0 && unlock_status) begin
            if (i_addr == 0 || i_addr == 1) begin
                address_register[i_addr] <= i_data_in;
            end else begin
                o_data_out <= 0;
            end
        end else if (i_read_write_enable == 0 && !unlock_status) begin
            o_data_out <= 0;
        end
    end

    // Reset logic
    always @(posedge i_rst_n) begin
        unlock_status <= 0;
        address_register[0] <= 0;
        address_register[1] <= 0;
    end

endmodule
