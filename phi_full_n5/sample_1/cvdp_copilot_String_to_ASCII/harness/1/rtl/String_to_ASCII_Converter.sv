// Sequential logic
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
            valid <= 1'b0;
            ascii_out <= 8'd0; // Initialize ascii_out to 0 for all bits
        end else if (active) begin
            // Process current character
            if (index < 8) begin
                // Calculate ASCII value for current character
                case (char_type)
                    DIGIT:   ascii_out <= char_in[index] + DIGIT_OFFSET;
                    UPPER:   ascii_out <= (char_in[index] - 8'd10) + UPPER_OFFSET;
                    LOWER:   ascii_out <= (char_in[index] - 8'd36) + LOWER_OFFSET;
                    SPECIAL: ascii_out <= (char_in[index] - 8'd62) + SPECIAL_OFFSET;
                    default: ascii_out <= 8'd0;
                endcase
                // Latch current ASCII value
                valid <= 1'b1;
                index <= index + 1;
            end else begin
                // Finish conversion
                active <= 1'b0;
                ready <= 1'b1;
                valid <= 1'b0;
                // No need to reset ascii_out here, as it is already initialized to 0
            end
        end
    end
end
