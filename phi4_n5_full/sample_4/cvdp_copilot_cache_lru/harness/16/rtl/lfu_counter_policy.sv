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

    // Maximum frequency value based on counter width
    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array: for each cache set (indexed by "index"), a vector of frequency counters for each way.
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    // Loop variables for initialization and scanning.
    integer i, n;

    // Sequential logic: reset and frequency updates occur on rising clock edge or asynchronous reset.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset: Initialize all frequency counters to 0 for every set and way.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= 0;
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // Hit: Update the frequency counter for the accessed way.
                    // Convert the bit-vector way_select to an integer index.
                    int unsigned accessed_way = way_select;
                    logic [COUNTERW-1:0] curr_freq;
                    curr_freq = frequency[index][(accessed_way * COUNTERW) +: COUNTERW];

                    if (curr_freq < MAX_FREQUENCY) begin
                        // Increment the counter if it hasn't reached MAX_FREQUENCY.
                        frequency[index][(accessed_way * COUNTERW) +: COUNTERW] <= curr_freq + 1;
                    end else begin
                        // If already at MAX_FREQUENCY, decrement counters of other ways that are greater than 2.
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != accessed_way) begin
                                logic [COUNTERW-1:0] other_freq;
                                other_freq = frequency[index][(n * COUNTERW) +: COUNTERW];
                                if (other_freq > 2) begin
                                    frequency[index][(n * COUNTERW) +: COUNTERW] <= other_freq - 1;
                                end
                            end
                        end
                    end
                end else begin
                    // Miss: Determine the least frequently used way for replacement.
                    int unsigned min_way;
                    logic [COUNTERW-1:0] min_val, curr_val;
                    // Initialize min_val to the maximum possible frequency and min_way to 0.
                    min_val = MAX_FREQUENCY;
                    min_way = 0;
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        curr_val = frequency[index][(n * COUNTERW) +: COUNTERW];
                        if (curr_val < min_val) begin
                            min_val = curr_val;
                            min_way = n;
                        end else if (curr_val == min_val && n < min_way) begin
                            // Tie-breaker: select the way with the lower index.
                            min_way = n;
                        end
                    end
                    // Set the frequency counter of the replaced way to 1.
                    frequency[index][(min_way * COUNTERW) +: COUNTERW] <= 1;
                    // Output the replacement way.
                    way_replace <= min_way;
                end
            end
        end
    end

endmodule