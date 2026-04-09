always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        remainder <= 8'd0;
    else if (start && !busy)
        remainder <= 8'd0;
    else if (busy && bit_counter == 4'd0) begin
        if (next_rem[7:0] != 8'd0)
            remainder <= next_rem[7:0]; // Removed the '+ 1'b1'
        else
            remainder <= 8'd0; // Changed from next_rem[7:0] + 1'b1 to 8'd0
    end
end
