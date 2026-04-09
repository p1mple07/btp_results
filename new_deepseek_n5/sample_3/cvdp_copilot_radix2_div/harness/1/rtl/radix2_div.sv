// ... [previous code remains unchanged] ...

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            remainder <= 8'd0;
        else if (start && !busy)
            remainder <= 8'd0;
        else if (busy)
            remainder <= next_rem[7:0];
    end

// ... [rest of the code remains unchanged] ...