module lfu_counter_policy #(
    parameter NWAYS    = 4,         // Number of cache ways (must be power of 2, at least 4)
    parameter NINDEXES = 32,        // Number of cache sets (must be power of 2)
    parameter COUNTERW = 2           // Width of frequency counters (at least 2)
)(
    input  logic clock,
    input  logic reset,
    input  logic [$clog2(NINDEXES)-1:0] index,
    input  logic [$clog2(NWAYS)-1:0] way_select,
    input  logic access,
    input  logic hit,
    output logic [$clog2(NWAYS)-1:0] way_replace
);

    // Maximum frequency value based on counter width
    localparam int unsigned MAX_FREQUENCY = (1 << COUNTERW) - 1;

    // Frequency array:
    // For each cache set (indexed by index), we maintain a vector of counters for each way.
    // Each counter is COUNTERW bits wide.
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    // Loop variables for initialization and updates
    integer i, n;

    // Sequential logic for reset and frequency updates.
    // All operations (hit/miss handling and replacement logic) complete in a single clock cycle.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset: Initialize all frequency counters to 0.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= {(COUNTERW){1'b0}};
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // ---------------------------------------------------------------
                    // HIT HANDLING:
                    // Increment the frequency counter for the accessed way if it hasn't reached MAX_FREQUENCY.
                    // If the counter is already at MAX_FREQUENCY, decrement the counters of the other ways
                    // that have a counter value higher than 2. This prevents stalling on the first way.
                    // ---------------------------------------------------------------
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] < MAX_FREQUENCY) begin
                        frequency[index][(way_select * COUNTERW) +: COUNTERW] <= 
                            frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                    end else begin
                        // Accessed way is saturated; adjust other ways.
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select) begin
                                if (frequency[index][(n * COUNTERW) +: COUNTERW] > 2)
                                    frequency[index][(n * COUNTERW) +: COUNTERW] <= 
                                        frequency[index][(n * COUNTERW) +: COUNTERW] - 1;
                            end
                        end
                    end
                    // For hit cycles, no replacement is needed. Drive a default value.
                    way_replace = '0;
                end else begin
                    // ---------------------------------------------------------------
                    // MISS HANDLING:
                    // On a cache miss, determine the least frequently used way.
                    // In the event of a tie, select the way with the lower index.
                    // Then, set the counter of the selected replacement way to 1.
                    // ---------------------------------------------------------------
                    integer candidate;
                    logic [COUNTERW-1:0] min_val;
                    candidate = 0;
                    // Initialize min_val to the maximum possible counter value.
                    min_val = MAX_FREQUENCY;
                    // Iterate over all ways to find the one with the minimum frequency.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (frequency[index][(n * COUNTERW) +: COUNTERW] < min_val) begin
                            min_val = frequency[index][(n * COUNTERW) +: COUNTERW];
                            candidate = n;
                        end
                    end
                    // Update the counter of the replacement candidate to 1.
                    frequency[index][(candidate * COUNTERW) +: COUNTERW] <= 1;
                    // Drive the replacement output.
                    way_replace = candidate;
                end
            end else begin
                // No access: Drive default value for way_replace.
                way_replace = '0;
            end
        end
    end

endmodule