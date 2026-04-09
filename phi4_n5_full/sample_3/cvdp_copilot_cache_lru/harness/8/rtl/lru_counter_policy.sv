// File: rtl/lru_counter_policy.sv

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
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Local parameter for counter size (number of bits per counter)
    localparam int cnt_size = $clog2(NWAYS);

    // Recency array: For each cache set (indexed by 'index'),
    // there are NWAYS counters, each of size 'cnt_size' bits.
    reg [(NWAYS * cnt_size)-1:0] recency [NINDEXES-1:0];

    // Internal register for LRU slot (used for replacement logic)
    reg [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    // ----------------------------------------------------------------
    // Sequential Logic: Update recency array on cache access events.
    // All updates are synchronized to the clock.
    // ----------------------------------------------------------------
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialization: Set each counter to a unique value (0 to NWAYS-1)
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * cnt_size) +: cnt_size] <= n;
                end
            end
        end else if (access) begin
            // Recency Update Logic
            // Declare local variables for the update loop.
            logic [cnt_size-1:0] old_val, new_val;
            if (hit) begin
                // On cache hit:
                //  - Read the old counter value for the accessed way.
                //  - Set the accessed way's counter to maximum (NWAYS-1).
                //  - Decrement all other counters that have a value greater than the old value.
                old_val = recency[index][way_select*cnt_size +: cnt_size];
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (n == way_select) begin
                        new_val = NWAYS - 1;
                    end else if (recency[index][n*cnt_size +: cnt_size] > old_val) begin
                        new_val = recency[index][n*cnt_size +: cnt_size] - 1;
                    end else begin
                        new_val = recency[index][n*cnt_size +: cnt_size];
                    end
                    recency[index][n*cnt_size +: cnt_size] <= new_val;
                end
            end else begin
                // On cache miss:
                //  - Find the way with the minimum counter value (0) for replacement.
                //  - Set that way's counter to maximum (NWAYS-1).
                //  - Decrement all counters with a value greater than 0.
                integer replaced_way;
                replaced_way = 0;
                // Find the first way with counter value 0.
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[index][n*cnt_size +: cnt_size] == 0) begin