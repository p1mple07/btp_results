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
                // Set the frequency counter of the accessed way
                integer access_way = way_select[0] * NWAYS + way_select[1];
                frequency[index][(access_way * COUNTERW) +: COUNTERW] <= frequency[index][(access_way * COUNTERW) +: COUNTERW] + 1;

                // Decrement counters of other ways if the accessed way has reached MAX_FREQUENCY
                if (frequency[index][(access_way * COUNTERW) +: COUNTERW] == MAX_FREQUENCY) begin
                    integer other_ways[NWAYS-1:0];
                    integer other_counters[NWAYS-1:0];
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        other_ways[n] = n;
                        other_counters[n] = frequency[index][(other_ways[n] * COUNTERW) +: COUNTERW];
                    end
                    foreach (other_ways[n]) begin
                        frequency[index][(other_ways[n] * COUNTERW) +: COUNTERW] <= other_counters[n] - 1;
                    end
                end
            end
        end
    end

    // Logic to determine the least frequently used way
    always_comb begin
        integer lfu_way;
        lfu_way = -1;
        integer min_counter = MAX_FREQUENCY + 1;
        integer i, n;
        for (i = 0; i < NINDEXES; i = i + 1) begin
            for (n = 0; n < NWAYS; n = n + 1) begin
                if (frequency[i][(n * COUNTERW) +: COUNTERW] < min_counter) begin
                    min_counter = frequency[i][(n * COUNTERW) +: COUNTERW];
                    lfu_way = i;
                end
            end
        end
        // Select way_replace with the least frequently used way
        way_replace = lfu_way[0] * NWAYS + lfu_way[1];
    end

endmodule : lfu_counter_policy
