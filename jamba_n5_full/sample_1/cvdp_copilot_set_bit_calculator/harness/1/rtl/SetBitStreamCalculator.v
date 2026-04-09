reg [p_max_set_bit_count_width-1:0] cnt;
reg async_reset;

always @(posedge i_clk) begin
    if (i_ready) begin
        async_reset = 1;
    end else begin
        async_reset = 0;
    end
end

always @(async_reset or i_rst_n) begin
    if (async_reset) begin
        cnt <= 0;
    end else begin
        if (i_rst_n) begin
            cnt <= 0;
        end else begin
            if (i_bit_in) begin
                if (cnt == MAX_COUNT-1) begin
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end
end

assign o_set_bit_count = cnt;
