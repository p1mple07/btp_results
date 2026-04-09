always @ (posedge clk_i) begin
    if (rst_i) begin
        // reset timer
        timeout_timer <= 8'd0;
        timeout_occurred <= 1'b0;
    end else begin
        if (read_accept_w) begin
            timeout_occurred <= 1'b0;
        end else begin
            if (timeout_timer >= TRANSACTION_TIMEOUT_THRESHOLD) begin
                timeout_occurred <= 1'b1;
            end else begin
                timeout_timer <= timeout_timer + 1;
            end
        end
    end
end
