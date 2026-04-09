// Modified generate block for final sum calculation
generate
    for (i = 0; i < WIDTH; i = i + 1) begin
        assign S[i] = P[i] ^ C[i];  // Corrected to compute final sum
    end
endgenerate

// Modified always block to correctly assign carry and sum
always @(posedge clk) begin
    if (reset) begin
        S <= 0; 
        carry <= 0;
        for (i = WIDTH-1; i > 0; i = i - 1) begin
            S[i] <= C[i]; // Correctly propagate carry to higher-order sum
        end
    end else begin
        S <= S1;
        carry <= carry1;
    end
end
