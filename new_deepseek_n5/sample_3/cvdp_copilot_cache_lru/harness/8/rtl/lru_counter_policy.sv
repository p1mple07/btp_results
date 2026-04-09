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

    // Recency array: each index has NWAYS ways, each with a counter of log2(NWAYS) bits
    reg [(NWAYS * $clog2(NWAYS))-1:0][NINDEXES-1:0][NWAYS-1:0] recency;

    wire lru_slot_found;
    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize recency array to default values (0 to NWAYS-1)
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][n] = n;
                end
            end
        end else begin
            // Cache Hit Handling
            if (access) begin
                if (hit) begin
                    // Update the accessed way to be the most recently used
                    way = way_select;
                    // Set the way's counter to the maximum value
                    recency[index][way] = NWAYS - 1;
                    // Decrement counters for other ways if they were more recently used
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != way) begin
                            if (recency[index][n] > recency[index][way]) begin
                                recency[index][n] = recency[index][n] - 1;
                            end
                        end
                    end
                end else begin
                    // No action needed for non-hit access
                end
            end else begin
                // Cache Miss Handling
                // Find the way with the minimum counter value
                integer min_index, min_value;
                min_index = 0;
                min_value = recency[index][0];
                for (n = 1; n < NWAYS; n = n + 1) begin
                    if (recency[index][n] < min_value) begin
                        min_index = n;
                        min_value = recency[index][n];
                    end
                end
                // Select the way with the minimum counter for replacement
                way_replace = min_index;
                // Update the replaced way's counter to the maximum value
                recency[index][way_replace] = NWAYS - 1;
                // Decrement counters for other ways if they were more recently used
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (n != way_replace) begin
                        if (recency[index][n] > recency[index][way_replace]) begin
                            recency[index][n] = recency[index][n] - 1;
                        end
                    end
                end
            end
        end
    end
endmodule