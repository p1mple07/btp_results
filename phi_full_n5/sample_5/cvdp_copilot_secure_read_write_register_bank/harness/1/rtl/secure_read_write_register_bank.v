module secure_read_write_register_bank (
    input [p_addr_width-1:0] i_addr,
    input [p_data_width-1:0] i_data_in,
    input i_read_write_enable,
    input i_capture_pulse,
    input i_rst_n,
    output reg [p_data_width-1:0] o_data_out
);

    parameter p_addr_width = 8;
    parameter p_data_width = 8;
    parameter p_unlock_code_0 = 0xAB;
    parameter p_unlock_code_1 = 0xCD;

    reg [p_data_width-1:0] unlock_status [2:0];

    // Unlock status register
    always @(posedge i_capture_pulse or negedge i_rst_n) begin
        if (!i_rst_n) begin
            unlock_status <= {3'b0, 3'b0, 3'b0};
        end else begin
            if (i_capture_pulse && unlock_status[0] == 0) begin
                unlock_status <= {1'b0, i_data_in, 3'b0};
            end
            if (i_capture_pulse && unlock_status[1] == 0) begin
                unlock_status <= {unlock_status[0], 1'b0, i_data_in};
            end
        end
    end

    // Read and Write control
    always @(posedge i_capture_pulse) begin
        if (!i_rst_n) begin
            o_data_out <= 0;
        end else if (i_read_write_enable == 1 && unlock_status[0] == 1 && unlock_status[1] == 1) begin
            o_data_out <= i_data_in;
        end

        if (i_read_write_enable == 0) begin
            if (unlock_status[0] == 1 && unlock_status[1] == 1) begin
                o_data_out <= i_data_in;
            end else begin
                o_data_out <= 0;
            end
        end
    end

    // Restricted access for addresses 0 and 1
    always @(i_addr) begin
        if (i_addr == 0 || i_addr == 1) begin
            o_data_out <= 0;
        end
    end

endmodule
