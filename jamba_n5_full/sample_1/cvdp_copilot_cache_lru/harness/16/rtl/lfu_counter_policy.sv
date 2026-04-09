module lfu_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32,
    parameter COUNTERW = 2
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array to track next way to be replaced
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    integer i, n;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        end else begin
            if (access) begin

            end
        end
    end

endmodule

// Main body of the module
always_ff @(posedge clock) begin
    if (access) begin
        if (hit) begin
            // Increment the counter for the accessed way
            frequency[index * COUNTERW + way_select] = frequency[index * COUNTERW + way_select] + 1;
            if (frequency[index * COUNTERW + way_select] == MAX_FREQUENCY) begin
                // Decrement counters of other ways that have a counter > 2
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (i != way_select) begin
                        frequency[i][(n * COUNTERW) + COUNTERW] <= frequency[i][COUNTERW] + 1;
                    end
                end
            end
        end
    end

    // Find the least frequently used way
    int best_freq = INF;
    int best_idx = -1;
    for (i = 0; i < NWAYS; i = i + 1) begin
        for (j = 0; j < COUNTERW; j = j + 1) begin
            if (frequency[i][(n * COUNTERW) + j] < best_freq) begin
                best_freq = frequency[i][(n * COUNTERW) + j];
                best_idx = i;
            end
        end
    end

    // Handle ties by selecting the lowest index
    if (best_freq < frequency[way_replace]) begin
        way_replace = best_idx;
    end else if (best_freq == frequency[way_replace]) begin
        way_replace = min(way_replace, best_idx);
    end

    // Set the counter for the replaced way to 1
    frequency[way_replace][(n * COUNTERW) + COUNTERW] = 1;

    // Update the output
    way_replace = way_replace;
end
