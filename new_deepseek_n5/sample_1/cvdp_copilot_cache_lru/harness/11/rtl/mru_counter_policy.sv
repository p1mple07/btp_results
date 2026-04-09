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

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        else begin
            if (access) begin
                // Update recency on cache hit
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (way_select == n) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)-1;
                        else if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > $clog2(NWAYS)-1) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                        end
                    end
                end
            end else begin
                // Find MRU slot for replacement
                integer max_counter = -1;
                integer mru_index = 0;
                integer mru_way = 0;
                
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (recency[i][n] > max_counter) begin
                            max_counter = recency[i][n];
                            mru_index = i;
                            mru_way = n;
                        end
                    end
                end
                way_replace <= mru_way;
                // Update recency on cache miss
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (way_select == n) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)-1;
                        else if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > $clog2(NWAYS)-1) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                        end
                    end
                end
            end
        end
    end
endmodule