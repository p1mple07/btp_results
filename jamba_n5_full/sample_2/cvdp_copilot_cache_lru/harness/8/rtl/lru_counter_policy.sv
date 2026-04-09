module lru_counter_policy #(
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

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency;

    // Initialize recency on reset
    always_ff @(reset) begin
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
            end
        end
    end

endmodule : lru_counter_policy
