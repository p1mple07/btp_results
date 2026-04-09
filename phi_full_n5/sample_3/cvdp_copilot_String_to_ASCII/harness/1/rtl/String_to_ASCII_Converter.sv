always @(posedge clk or posedge reset) begin
    if (reset) begin
        index       <= 4'd0;
        ascii_out   <= 8'd0;
        valid       <= 1'b0;
        ready       <= 1'b1;
        active      <= 1'b0;
    end else begin
        if (start && ready) begin
            // Start conversion
            ready <= 1'b0;
            active <= 1'b1;
            index <= 4'd0;
            ascii_out <= 8'd0; // Latch initial value immediately
            valid <= 1'b1; // Indicate valid output immediately
        end else if (active) begin
            // Process current character
            if (index < 8) begin
                ascii_out <= intermediate_ascii; // Latch current ASCII value immediately
                valid <= 1'b1; // Indicate valid output immediately
                index <= index + 1;
            end else begin
                // Finish conversion
                active <= 1'b0;
                ready <= 1'b1;
                valid <= 1'b0;
            end
        end
    end
end
