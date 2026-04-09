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
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Each cache set (indexed by 'index') holds NWAYS counters.
    // Each counter is $clog2(NWAYS) bits wide.
    // The entire recency array for a given index is stored as a concatenated bit-vector.
    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // This register will hold the MRU (most recently used) way index,
    // computed combinational from the recency array.
    reg [$clog2(NWAYS)-1:0] mru_slot;

    integer i, n;

    // Sequential block: update the recency array on clock edge or asynchronous reset.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize each counter to a unique value (0 to NWAYS-1) in ascending order.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end
        else begin
            if (access) begin
                if (hit) begin
                    // ------------------------------
                    // Cache Hit Update:
                    //   - Set the accessed way's counter to the maximum value (NWAYS-1).
                    //   - Decrement all other counters that are greater than the previous value.
                    // ------------------------------
                    integer old_value;
                    // Capture the current counter value for the accessed way.
                    old_value = recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)];
                    // Set the accessed way's counter to maximum.
                    recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS - 1;
                    // Decrement counters in other ways that exceed the old value.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != way_select) begin
                            if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > old_value) begin
                                recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= 
                                    recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                            end
                        end
                    end
                end
                else begin
                    // ------------------------------
                    // Cache Miss Update:
                    //   - Determine the MRU way (the one with the maximum counter value).
                    //   - Set that way's counter to the maximum value.
                    //   - Decrement all other counters that are greater than its previous value.
                    //   - This MRU way is then selected for replacement.
                    // ------------------------------
                    integer replaced_way, old_value;
                    replaced_way = 0;
                    // Find the MRU way based on the current counter values.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > 
                            recency[index][(replaced_way * $clog2(NWAYS)) +: $clog2(NWAYS)]) begin
                            replaced_way = n;
                        end
                    end
                    // Capture the counter value for the replaced way.
                    old_value = recency[index][(replaced_way * $clog2(NWAYS)) +: $clog2(NWAYS)];
                    // Set the replaced way's counter to maximum.
                    recency[index][(replaced_way * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS - 1;
                    // Decrement counters in other ways that exceed the old value.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != replaced_way) begin
                            if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > old_value) begin
                                recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= 
                                    recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                            end
                        end
                    end
                end
            end
        end
    end

    // ------------------------------
    // Combinational Logic: Determine the MRU slot for replacement.
    // This always_comb block scans the current counters for the given cache set (index)
    // and selects the way with the maximum counter value.
    // ------------------------------
    always_comb begin
        mru_slot = 0;
        for (n = 0; n < NWAYS; n = n + 1) begin
            if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > 
                recency[index][(mru_slot * $clog2(NWAYS)) +: $clog2(NWAYS)]) begin
                mru_slot = n;
            end
        end
    end

    // Drive the replacement output with the computed MRU slot.
    assign way_replace = mru_slot;

endmodule