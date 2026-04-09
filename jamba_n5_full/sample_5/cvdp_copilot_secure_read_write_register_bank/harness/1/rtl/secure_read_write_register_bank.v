module secure_read_write_register_bank (
    input wire      i_rst_n,
    input wire [p_addr_width-1:0] i_addr,
    input wire      i_data_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_addr_zero,   // unused, but kept for symmetry
    input wire i_addr_one,   // unused, but kept for symmetry
    input wire i_data_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_rst_n
);

    localparam address0 = 0;
    localparam address1 = 1;

    reg [p_addr_width-1:0] addr;
    reg [31:0] data;
    reg is_unlocked;
    reg unlocked_after_first;
    reg unlocked_after_second;

    always @(i_capture_pulse) begin
        if (i_rst_n) begin
            is_unlocked <= false;
            unlocked_after_first <= false;
            unlocked_after_second <= false;
        end else begin
            if (i_addr == address0) begin
                if (i_data_in == p_unlock_code_0) begin
                    unlocked_after_first <= true;
                end
            end else if (i_addr == address1) begin
                if (i_data_in == p_unlock_code_1) begin
                    unlocked_after_second <= true;
                end
            end

            if (is_unlocked && unlocked_after_first && unlocked_after_second) begin
                is_unlocked <= false;
            end else begin
                is_unlocked <= false;
            end
        end
    end

    assign o_data_out = (is_unlocked && i_read_write_enable) ? i_data_in : 0;

endmodule
