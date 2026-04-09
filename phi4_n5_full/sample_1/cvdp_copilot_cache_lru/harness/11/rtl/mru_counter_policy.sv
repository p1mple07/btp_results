// File: rtl/mru_counter_policy.sv
module mru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input         clock,
    input         reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input         access,
    input         hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    //--------------------------------------------------------------------------
    // Data Structure:
    // Each cache set (indexed by 'index') holds NWAYS counters.
    // Each counter is $clog2(NWAYS) bits wide.
    // The counters are stored contiguously in the vector 'recency[index]'.
    //--------------------------------------------------------------------------
    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // Internal signals for computing the MRU slot.
    reg [$clog2(NWAYS)-1:0] mru_slot;

    // Local variables for loop indices and temporary values.
    integer i, n;
    integer accessed_val, replaced_val, current, temp_max, temp_mru, mru;

    //--------------------------------------------------------------------------
    // Sequential Block:
    // Updates the recency array on cache access (hit or miss) in one clock cycle.
    // Uses blocking assignments to ensure single-cycle latency.
    //--------------------------------------------------------------------------
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            //--------------------------------------------------------------------------
            // Reset Behavior:
            // For each cache set, initialize the counters to a unique value (0 to NWAYS-1)
            // in ascending order.
            //--------------------------------------------------------------------------
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    // Each counter is initialized to its way number.
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    //--------------------------------------------------------------------------
                    // Cache Hit:
                    // - Get the old counter value for the accessed way.
                    // - Set the accessed way's counter to maximum (NWAYS-1).
                    // - Decrement any counter that was greater than the old value.
                    //--------------------------------------------------------------------------
                    accessed_val = recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)];
                    // Set accessed way to maximum.
                    recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)] = NWAYS-1;
                    // Adjust all other counters.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (