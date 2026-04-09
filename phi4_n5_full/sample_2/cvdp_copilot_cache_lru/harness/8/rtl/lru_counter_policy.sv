module lru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input  clock,
    input  reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0] way_select,
    input  access,
    input  hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Each cache set (indexed by 'index') holds NWAYS counters.
    // Each counter is $clog2(NWAYS) bits wide.
    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    integer i, n, j;
    // Local variable for counter width.
    int cw = $clog2(NWAYS);

    // Sequential block: update recency array and determine replacement way.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset Behavior:
            // Initialize each counter in every cache set to a unique value (0 to NWAYS-1)
            // in ascending order.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * cw) +: cw] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                // Recency Update Logic:
                // Get the current recency vector for the selected cache set.
                logic [(NWAYS * cw)-1:0] old_val = recency[index];
                // Make a copy to build the updated value.
                logic [(NWAYS * cw)-1:0] new_val = old_val;
                logic [cw-1:0] prev;
                
                if (hit) begin
                    // Cache Hit:
                    // The accessed way (given by way_select) is updated.
                    int accessed_way = way_select;
                    // Capture the previous counter value for the accessed way.
                    prev = old_val[accessed_way * cw +: cw];
                    // Set the accessed way's counter to maximum (most recently used).
                    new_val[accessed_way * cw +: cw] = $clog2(NWAYS)'(NWAYS-1);
                    // Decrement all counters greater than the previous value.
                    for (j = 0; j < NWAYS; j = j + 1) begin
                        if (j != accessed_way) begin
                            if (old_val[j * cw +: cw] > prev)
                                new_val[j * cw +: cw] = old_val[j * cw +: cw] - 1;
                        end
                    end
                end else begin
                    // Cache Miss:
                    // Identify the least recently used (LRU) way (minimum counter value).
                    int replaced_way = 0;
                    prev = old_val[0 * cw +: cw];
                    for (j = 1; j < NWAYS; j = j + 1) begin
                        if (old_val[j * cw +: cw] < prev) begin
                            prev = old_val[j * cw +: cw];
                            replaced_way = j;
                        end
                    end
                    // Set the replaced way's counter to maximum.
                    new_val[replaced_way * cw +: cw] = $clog2(NWAYS)'(NWAYS-1);
                    // Decrement all counters greater than the previous value of the replaced way.
                    for (j = 0; j < NWAYS; j = j + 1) begin
                        if (j != replaced_way) begin
                            if (old_val[j * cw +: cw] > prev)
                                new_val[j * cw +: cw] = old_val[j * cw +: cw] - 1;
                        end
                    end
                end
                
                // Write back the updated recency vector for the selected cache set.
                recency[index] <= new_val;
                
                // Replacement Logic:
                // Determine the LRU way (the one with the minimum counter value) from the updated vector.
                int lru = 0;
                logic [cw-1:0] min_val = new_val[0 * cw +: cw];
                for (j = 1; j < NWAYS; j = j + 1) begin
                    if (new_val[j * cw +: cw] < min_val) begin
                        min_val = new_val[j * cw +: cw];
                        lru = j;
                    end
                end
                // Drive the replacement output.
                way_replace <= lru;
            end else begin
                // No access: no update; drive replacement output to a default value.
                way_replace <= 0;
            end
        end
    end

endmodule