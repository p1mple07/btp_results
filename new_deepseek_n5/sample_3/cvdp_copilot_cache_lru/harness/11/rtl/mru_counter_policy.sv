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

    integer i, n, max_counter, max_index, max_way;

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        else begin
            if (access) begin
                // Update recency array on hit
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (way_select == n) begin
                            // Set current way to max value
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= (NWAYS-1);
                            // Decrement counters greater than previous value
                            for (m = 0; m < NWAYS; m = m + 1) begin
                                if (m != n) begin
                                    if (recency[i][m * $clog2(NWAYS) +: $clog2(NWAYS)] > (n)) begin
                                        recency[i][m * $clog2(NWAYS) +: $clog2(NWAYS)] <= recency[i][m * $clog2(NWAYS) +: $clog2(NWAYS)] - 1;
                                    end
                                end
                            end
                        end
                    end
                end
                // Find max counter for replacement
                max_counter = 0;
                max_index = 0;
                max_way = 0;
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (recency[i][n * $clog2(NWAYS) +: $clog2(NWAYS)] > max_counter) begin
                            max_counter = recency[i][n * $clog2(NWAYS) +: $clog2(NWAYS)];
                            max_index = i;
                            max_way = n;
                        end
                    end
                end
                way_replace = max_way;
            end
        end
    end

    assign way_replace = 0;

    // Ensure way_replace is assigned even if no access
    assign way_replace = 0;
endmodule