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

    // Initialize the recency array on reset
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                // Cache hit: Update the MRU slot and decrement other counters
                mru_slot = way_select;
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] == (NWAYS - 1)) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n + 1);
                        end else if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > (NWAYS - 1)) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                        end
                    end
                end
            end
        end
    end

    // Determine the MRU slot for replacement
    always_comb begin
        mru_slot = -1;
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] == (NWAYS - 1)) begin
                    mru_slot = way_select;
                    break; // Exit the loop once the MRU slot is found
                end
            end
            if (mru_slot != -1) break; // Exit the loop if MRU slot is found
        end
    end

    // Assign the MRU slot to way_replace
    assign way_replace = mru_slot;

endmodule : mru_counter_policy
