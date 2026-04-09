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

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // Initialize recency array to unique values 0 to NWAYS-1
    initial begin
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
            end
        end
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset counters to initial state
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin

            // Hit case
            if (access == 1 && hit == 1) begin
                // Set the accessed way to maximum recency
                recency[index][way_select] <= $clog2(NWAYS) - 1;

                // Decrement other counters
                for (j = 0; j < NWAYS; j = j + 1) begin
                    if (j != index) begin
                        if (recency[j][way_select] > $clog2(NWAYS) - 1) begin
                            recency[j][way_select] <= 1'b0;
                        end
                    end
                end
            end

            // Miss case
            if (access == 1 && hit == 0) begin
                // Find the least recently used way
                reg min_recency, idx;
                integer min_val;
                integer idx_temp;

                initial @(posedge clock);

                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (recency[i][idx_temp] < min_val) begin
                            min_val = recency[i][idx_temp];
                            idx_temp = i;
                        end
                    end
                end

                min_recency = min_val;

                // Find the index with min_recency
                for (j = 0; j < NWAYS; j = j + 1) begin
                    if (recency[j][idx_temp] == min_recency) begin
                        lru_slot = j;
                        break;
                    end
                end

                // Update recency array for replacement
                recency[lru_slot][way_select] <= $clog2(NWAYS) - 1;

                // Set way_replace to lru_slot
                way_replace = lru_slot;

                // Decrement other counters
                for (k = 0; k < NWAYS; k = k + 1) begin
                    if (k != lru_slot) begin
                        if (recency[k][way_select] > $clog2(NWAYS) - 1) begin
                            recency[k][way_select] <= 1'b0;
                        end
                    end
                end
            end

        end
    end

endmodule
