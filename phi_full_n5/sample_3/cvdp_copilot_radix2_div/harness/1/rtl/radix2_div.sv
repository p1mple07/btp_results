always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        remainder <= 8'd0;
    else if (start && !busy && divisor == 8'd0)
        remainder <= 8'hFF;
    else if (busy && bit_counter == 4'd0) begin
        if (next_rem[7:0] != 8'd0)
            remainder <= next_rem[7:0];
        else
            remainder <= next_rem[7:0] + 1'b0; // Corrected line: Remove the '+ 1' to match the expected behavior
    end
end
