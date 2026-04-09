module secure_read_write_register_bank #(
    parameter p_address_width = 8,
    parameter p_data_width = 8
)(
    input wire [p_addr_width-1:0] i_addr,
    input wire i_data_in,
    input wire i_read_write_enable,
    input wire i_capture_pulse,
    input wire i_rst_n,
    output reg o_data_out
);

reg [31:0] state;
reg is_unlocked;

initial begin
    state = 32'h0;
    is_unlocked = 0;
end

always @(posedge i_capture_pulse or negedge i_rst_n) begin
    if (i_rst_n) begin
        state = 32'd0;
        is_unlocked = 0;
    end else begin
        if (i_rst_n) begin
            state = 32'd0;
        end else begin
            if (i_read_write_enable) begin
                if (state[2:0] == 8'b0 && i_data_in == p_unlock_code_0) begin
                    state[2:0] = 8'b111;
                end else if (state[2:0] == 8'b111 && i_data_in == p_unlock_code_1) begin
                    state[2:0] = 8'b111;
                end
            end else begin
                state = 32'd0;
            end
        end
    end
end

always @(*) begin
    if (~is_unlocked) begin
        o_data_out = 1'b0;
    end else begin
        if (i_addr == 0 && i_data_in == p_unlock_code_0 && state[2:0] == 8'b111) begin
            o_data_out = p_data_width;
        end else if (i_addr == 1 && i_data_in == p_unlock_code_1 && state[2:0] == 8'b111) begin
            o_data_out = p_data_width;
        end else if (i_addr != 0 && i_addr != 1) begin
            o_data_out = 1'b0;
        end else if (i_addr == 0 && i_data_in == 0) begin
            o_data_out = 0;
        end else if (i_addr == 1 && i_data_in == 0) begin
            o_data_out = 0;
        end else if (i_addr == 0 && i_data_in == 0) begin
            o_data_out = 0;
        end else if (i_addr == 1 && i_data_in == 0) begin
            o_data_out = 0;
        end else if (i_addr == 0 && i_data_in == 0) begin
            o_data_out = 0;
        end else if (i_addr == 1 && i_data_in == 0) begin
            o_data_out = 0;
        end
    end
end

endmodule
