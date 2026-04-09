always_ff @ (posedge clock) begin
    if (reset) begin
        for (i = 0; i < NINDEXES; i++) begin
            recency[i] <= NBITS_TREE'(0);
        end
    end
end
