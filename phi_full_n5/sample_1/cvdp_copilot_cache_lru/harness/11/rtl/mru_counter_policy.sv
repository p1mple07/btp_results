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

    // Initialize recency array with unique values from 0 to NWAYS-1
    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // Register to hold the most recently used (MRU) slot
    reg [$clog2(NWAYS)-1:0] mru_slot;

    // Loop variables for array indexing
    integer i, n;

    // Reset logic
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end
    end

    // Hit logic: Update recency array and select MRU slot
    always_comb begin
        if (access) begin
            mru_slot = 0; // Start with the assumption that no way is selected
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] == NWAYS-1) begin
                    mru_slot = n; // MRU way is found
                    break;
                end
            end

            // Update the recency array on a cache hit
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (n != mru_slot) begin
                    recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                end
            end

            // Set the accessed way to the MRU slot
            recency[index][(mru_slot * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS-1;
        end
    end

    // Assign the MRU slot to the output
    assign way_replace = mru_slot;

endmodule : mru_counter_policy
