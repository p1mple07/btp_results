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

    // Reset logic
    always_ff @(reset) begin
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                recency[i][(NWAYS * $clog2(NWAYS))-1 :0] <= $clog2(NWAYS)'(n);
            end
        end
    end

    // Hit logic
    always_ff @(posedge clock) begin
        if (access) begin
            // Find the way with the smallest recency value
            localvar int lru_slot;
            recency[0]; // initialize to something large, but we can iterate
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (recency[i] < lru_slot) begin
                    lru_slot = recency[i];
                    lru_slot_found = i;
                end
            end

            // Set the accessed way's counter to the maximum
            recency[index][(NWAYS * $clog2(NWAYS))-1 :0] <= target_recency;

            // Decrement all other counters
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (i != index) recency[i] <= recency[i] - 1;
            end

            // Assign way_replace to the found index
            way_replace = index[lru_slot_found];
        end else begin
            // Miss logic
            localvar int lru_slot;
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (recency[i] == 0) begin
                    lru_slot = i;
                    break;
                end
            end

            // Set the replaced way's counter to maximum
            recency[lru_slot_found] = NWAYS - 1;

            // Decrement all other counters
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (i != lru_slot_found) recency[i] <= recency[i] - 1;
            end

            // Assign way_replace to the replaced way
            way_replace = lru_slot_found;
        end
    end

endmodule
