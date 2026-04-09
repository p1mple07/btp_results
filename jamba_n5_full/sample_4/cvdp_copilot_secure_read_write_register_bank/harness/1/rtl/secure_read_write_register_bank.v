module secure_read_write_register_bank #(
    parameter PAD_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input wire i_rst_n,
    input wire i_rst,
    input wire i_capture_pulse,
    input wire i_addr[PAD_WIDTH-1],
    input wire i_data_in,
    input wire i_read_write_enable,
    input wire i_write_enable,
    output reg o_data_out
);

reg [1:0] state;
reg is_unlocked;

always @(posedge i_capture_pulse) begin
    if (i_rst_n) begin
        state <= 2'd2;
        is_unlocked <= 1'b1;
    end else begin
        case (state)
            STATE_LOCKED: begin
                if (i_rst_n) state <= STATE_LOCKED;
                else begin
                    state <= STATE_LOCKED;
                end
            end
            STATE_FIRST_OK: begin
                if (i_rst_n) state <= STATE_LOCKED;
                else begin
                    if (i_rst) state <= STATE_LOCKED;
                    else begin
                        if (i_addr[0] == PAD_WIDTH-1 && i_data_in == p_unlock_code_0)
                            state <= STATE_SECOND_OK;
                        else
                            state <= STATE_FIRST_OK;
                    end
                end
            end
            STATE_SECOND_OK: begin
                if (i_rst_n) state <= STATE_UNLOCKED;
                else begin
                    state <= STATE_UNLOCKED;
                end
            end
            STATE_UNLOCKED: begin
                o_data_out <= i_data_in;
            end
        endcase
    end
end

endmodule
