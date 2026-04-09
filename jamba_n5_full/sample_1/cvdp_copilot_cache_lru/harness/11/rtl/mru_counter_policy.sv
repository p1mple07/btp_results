module mru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    wire [$clog2(NWAYS)-1:0] mru_slot;

    integer i, n;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1)
                for (n = 0; n < NWAYS; n = n + 1)
                    recency[i][(n * $clog2(NWAYS)) + : $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
        end else begin
            if (access) begin
                // Hit: set the accessed way to most recent
                let idx = index;
                let w = way_select;
                recency[idx][w * $clog2(NWAYS) + : $clog2(NWAYS)] <= $clog2(NWAYS) - 1;
                for (n = 0; n < NWAYS; n = n + 1)
                    if (n != w) recency[idx][n * $clog2(NWAYS) + : $clog2(NWAYS)] <= $clog2(NWAYS);
            end
            else begin
                // Miss: find the maximum recency
                mru_slot = -1;
                max_index = 0;
                for (i = 0; i < NINDEXES; i = i + 1)
                    for (n = 0; n < NWAYS; n = n + 1)
                        if (recency[i][n * $clog2(NWAYS) + : $clog2(NWAYS)] > mru_slot)
                            mru_slot = recency[i][n * $clog2(NWAYS) + : $clog2(NWAYS)];
                            max_index = i;
                way_replace = max_index;

                // Assign MRU counters
                recency[max_index][mru_slot * $clog2(NWAYS) + : $clog2(NWAYS)] <= $clog2(NWAYS) - 1;
                for (n = 0; n < NWAYS; n = n + 1)
                    if (n != mru_slot) recency[max_index][n * $clog2(NWAYS) + : $clog2(NWAYS)] <= $clog2(NWAYS);
            end
        end
    end

    assign way_replace = mru_slot;

endmodule
