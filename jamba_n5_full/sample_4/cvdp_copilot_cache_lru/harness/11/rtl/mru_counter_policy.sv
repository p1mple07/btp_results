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
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                // Hit: set the hit way to the maximum recency
                reg max_recency;
                reg idx;
                for (i = 0; i < NWAYS*$clog2(NWAYS); i = i + 1) begin
                    for (j = 0; j < NWAYS*$clog2(NWAYS); j = j + 1)
                        if (j != i && recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_recency)
                            max_recency = recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)];
                            idx = i;
                end
                recency[idx][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS - 1;

                for (i = 0; i < NWAYS*$clog2(NWAYS); i = i + 1)
                    if (i != idx && recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_recency)
                        recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
            end
            else begin
                // Miss: select the way with the maximum recency
                reg max_recency;
                reg idx;
                for (i = 0; i < NWAYS*$clog2(NWAYS); i = i + 1) begin
                    for (j = 0; j < NWAYS*$clog2(NWAYS); j = j + 1)
                        if (j != i && recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_recency)
                            max_recency = recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)];
                            idx = i;
                end
                recency[idx][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS - 1;

                for (i = 0; i < NWAYS*$clog2(NWAYS); i = i + 1)
                    if (i != idx && recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_recency)
                        recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(way_select[NINDEXES-1:0] * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;

                assign way_replace = idx;
            end
        end
    end

endmodule
