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

    // Initialize recency array to zero (or a default value)
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin

        end
    end

    // Hit case: update the accessed way to the most recent (NWAYS-1)
    always_ff @(posedge clock or posedge reset) begin
        if (access && hit) begin
            recency[index] <= NWAYS - 1;

            // Decrement all other counters
            for (int n = 0; n < NWAYS; n++) begin
                if (n != index) begin
                    recency[n] <= recency[n] - 1;
                end
            end
        end
    end

    // Find the LRU way (minimum recency value)
    localvar int lru_slot;
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            lru_slot = 0;
        end else begin
            for (int n = 1; n < NWAYS; n++) begin
                if (recency[n] < recency[lru_slot]) lru_slot = n;
            end
        end
    end

    assign way_replace = lru_slot;

endmodule
