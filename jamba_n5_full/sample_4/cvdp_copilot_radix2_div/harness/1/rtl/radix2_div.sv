always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        quotient <= 8'd0;
    else if (start && !busy) begin
        if (divisor == 8'd0)
            quotient <= 8'hFF;
        else
            quotient <= 8'd0;
    end
    else if (busy) begin
        quotient[bit_counter] <= bit_set;
    end
end
