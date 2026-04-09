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

    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    // Recency Update Logic
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            // Cache hit: Update the accessed way and decrement other counters
            if (access) begin
                // Set the accessed way's counter to the maximum value
                recency[index][way_select] <= NWAYS - 1;
                // Decrement counters with a value greater than the previous value
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > recency[index][way_select]) begin
                        recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][way_select] - 1;
                    end
                end
            end

            // LRU Replacement Logic
            // Find the least recently used way for replacement
            assign lru_slot = 0;
            assign way_replace = 0;
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] < lru_slot) begin
                        lru_slot = recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)];
                        way_replace = n;
                    end
                end
            end
        end
    end

endmodule : lru_counter_policy
