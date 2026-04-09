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

    // Unlock state
    reg [p_data_width-1:0] unlock_status;

    // Unlock sequence completion signal
    reg unlock_sequence_complete;

    // Unlock sequence process
    always @(posedge i_capture_pulse or posedge i_rst_n) begin
        if (i_rst_n) begin
            unlock_status <= 0;
            unlock_sequence_complete <= 0;
        end else if (i_capture_pulse) begin
            if (unlock_status == 0) begin
                if (i_addr == 0) begin
                    unlock_status <= p_unlock_code_0;
                end else if (i_addr == 1) begin
                    unlock_status <= p_unlock_code_1;
                end
            end
            if (unlock_status == p_unlock_code_0 && unlock_status == p_unlock_code_1) begin
                unlock_sequence_complete <= 1;
            end
        end
    end

    // Read and write operations
    always @(posedge i_capture_pulse) begin
        if (i_rst_n) begin
            o_data_out <= 0;
        end else if (i_read_write_enable) begin
            if (unlock_sequence_complete) begin
                if (i_addr == 0 || i_addr == 1) begin
                    o_data_out <= 0; // Write-only addresses
                end else begin
                    o_data_out <= i_data_in;
                end
            end
        end
    end

endmodule
