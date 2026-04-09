always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
            end
        end
    end
end
