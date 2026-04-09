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
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Maximum counter value based on COUNTERW bits
    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array to track access counts for each cache way in each index.
    // Each cache set (indexed by 'index') holds NWAYS counters packed into a bit-vector.
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    integer i, n;

    // Sequential logic for reset and frequency updates.
    // All operations complete within a single clock cycle.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset: Initialize all frequency counters to 0 for every cache set.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    // Each counter slice is initialized to 0.
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= {COUNTERW{1'b0}};
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // -------------------------------
                    // Hit Scenario:
                    // -------------------------------
                    // 1. Increment the frequency counter for the accessed way if below MAX_FREQUENCY.
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] < MAX_FREQUENCY)
                        frequency[index][(way_select * COUNTERW) +: COUNTERW] <= 
                            frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                    
                    // 2. If the hit way is already at MAX_FREQUENCY,
                    //    decrement the counters of other ways that have a counter value higher than 2.
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] == MAX_FREQUENCY) begin
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select && frequency[index][(n * COUNTERW) +: COUNTERW] > 2)
                                frequency[index][(n * COUNTERW) +: COUNTERW] <= 
                                    frequency[index][(n * COUNTERW) +: COUNTERW] - 1;
                        end
                    end
                    // For a hit, drive the replacement output to the accessed way.
                    way_replace <= way_select;
                end else begin
                    // -------------------------------
                    // Miss Scenario:
                    // -------------------------------
                    // 1. Determine the least frequently used way.
                    //    In case of a tie, select the way with the lower index.
                    integer min_way, min_count;
                    min_way = 0;
                    min_count = frequency[index][(0 * COUNTERW) +: COUNTERW];
                    for (n = 1; n < NWAYS; n = n + 1) begin
                        if (frequency[index][(n * COUNTERW) +: COUNTERW] < min_count) begin
                            min_count = frequency[index][(n * COUNTERW) +: COUNTERW];
                            min_way = n;
                        end else if (frequency[index][(n * COUNTERW) +: COUNTERW] == min_count && n < min_way) begin
                            // Tie-breaker: select the way with the lower index.
                            min_way = n;
                        end
                    end
                    // 2. Set the counter of the replaced way to 1.
                    frequency[index][(min_way * COUNTERW) +: COUNTERW] <= 1;
                    // 3. Drive the replacement output to the selected way.
                    way_replace <= min_way;
                end
            end else begin
                // No access: No update. Default replacement output.
                way_replace <= 0;
            end
        end
    end

endmodule