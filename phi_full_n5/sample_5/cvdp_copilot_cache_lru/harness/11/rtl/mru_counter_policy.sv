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

    integer i, n;

    // Initialize the recency array to unique values on reset
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= n;
                end
            end
        end
    end

    // Update the recency array on a cache hit
    always_ff @ (posedge clock, access) begin
        if (access) begin
            recency[index][way_select] <= NWAYS-1; // Set the accessed way to MRU value
            // Decrement counters greater than the accessed way
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > NWAYS-1) begin
                    recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                end
            end
        end
    end

    // Determine the MRU slot for replacement
    always_comb begin
        mru_slot = 0;
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > mru_slot) begin
                    mru_slot = recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)];
                end
            end
        end
        // Assign the MRU slot to way_replace
        way_replace = mru_slot;
    end

endmodule : mru_counter_policy
