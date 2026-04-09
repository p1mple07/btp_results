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

    // Local wires for tracking LRU slot
    wire lru_slot_found;
    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    // Recency update logic on cache hit
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            // Cache hit scenario
            if (access) begin
                // Set the accessed way to the most recently used
                recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)] <= NWAYS - 1;

                // Decrement counters for all ways except the accessed way
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    if (i != index) begin
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (recency[i][n * $clog2(NWAYS) +: $clog2(NWAYS)] > 0) begin
                                recency[i][n * $clog2(NWAYS) +: $clog2(NWAYS)] <= recency[i][n * $clog2(NWAYS) +: $clog2(NWAYS)] - 1;
                            end
                        end
                    end
                end
            end
        end
    end

    // Replacement logic to determine the LRU way
    assign way_replace = 0;
    always_comb begin
        // Initialize minimum counter value
        integer min_counter = $clog2(NWAYS);
        wire [$clog2(NWAYS)-1:0] min_counter_wire;

        // Find the way with the minimum counter
        for (i = 0; i < NINDEXES; i = i + 1) begin
            if (recency[i] != 0 && recency[i] < min_counter) begin
                min_counter = recency[i];
                min_counter_wire = index[i];
            end
        end

        // Assign the LRU way to way_replace
        if (min_counter_wire != 0) begin
            way_replace = min_counter_wire;
        end
    end

endmodule : lru_counter_policy
