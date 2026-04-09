always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        remainder <= 8'd0;
    else if (start && !busy)
        remainder <= 8'd0;
    else if (busy && bit_counter == 4'd0) begin
        if (next_rem[7:0] != 8'd0)
            remainder <= next_rem[7:0];
        else
            remainder <= next_rem[7:0] - 1'b1; // Corrected logic here
    end
end
