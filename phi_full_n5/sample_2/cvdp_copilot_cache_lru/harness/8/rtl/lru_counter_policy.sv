module lru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [$clog2(NI) - 1:0] index,
    input [$clog2(NW) - 1:0] way_select,
    input access,
    input hit,
    output [$clog2(NW) - 1:0] way_replace
);

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NI-1:0];

    wire lru_slot_found;
    wire [$clog2(NW) - 1:0] lru_slot;

    integer i, n;

    // Recency Update Logic
    always_comb begin
        if (access && hit) begin
            // Set the accessed way to NWAYS-1 (most recently used)
            recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] = NWAYS - 1;

            // Decrement counters for all other ways
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (n != way_select) begin
                    recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] = recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                end
            end
        end
    end

    // Replacement Logic
    always_comb begin
        // Find the LRU slot for replacement
        lru_slot_found = 1'b0;
        lru_slot = {NWAYS{1'b0}};
        for (n = 0; n < NWAYS; n = n + 1) begin
            if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] < lru_slot) begin
                lru_slot_found = 1'b1;
                lru_slot = recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)];
            end
        end

        // Assign the LRU way to way_replace
        way_replace = lru_slot_found ? way_select : (way_select - 1'b1);
    end

endmodule : lru_counter_policy
