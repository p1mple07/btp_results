module lfu_counter_policy #(
    parameter NWAYS = 4,            // Number of ways (must be a power of 2 and at least 4)
    parameter NINDEXES = 32,         // Number of cache sets (must be a power of 2)
    parameter COUNTERW = 2           // Width of frequency counters (must be at least 2)
)(
    input  clock,
    input  reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0]    way_select,
    input  access,
    input  hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Maximum frequency value based on counter width (saturation limit)
    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array:
    // Each cache set (indexed by 'index') contains NWAYS counters.
    // Each counter is stored in COUNTERW consecutive bits.
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    // Loop indices for reset initialization
    integer i, n;

    // Sequential process: handles reset and frequency updates on each clock cycle.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset Behavior: Initialize all frequency counters to 0.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= '0;
                end
            end
        end
        else begin
            if (access) begin
                if (hit) begin
                    // Cache Access Update on Hit:
                    // 1. Set the frequency counter of the accessed way.
                    // 2. If the counter is below MAX_FREQUENCY, increment it.
                    // 3. If already at MAX_FREQUENCY, decrement the counters of other ways (if > 2)
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] < MAX_FREQUENCY) begin
                        frequency[index][(way_select * COUNTERW) +: COUNTERW] <= 
                            frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                    end
                    else begin
                        // Saturation reached: decrement other ways' counters if greater than 2.
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select) begin
                                if (frequency[index][(n * COUNTERW) +: COUNTERW] > 2) begin
                                    frequency[index][(n * COUNTERW) +: COUNTERW] <= 
                                        frequency[index][(n * COUNTERW) +: COUNTERW] - 1;
                                end
                            end
                        end
                    end
                end
                else begin
                    // Cache Access Update on Miss:
                    // 1. Identify the least frequently used way (minimum counter value).
                    // 2. In case of a tie, select the way with the lower index.
                    // 3. Set the counter of the replaced way to 1.
                    // 4. Output the selected replacement way.
                    
                    integer k;
                    integer min_way;
                    integer min_count;
                    logic [COUNTERW-1:0] current_count;
                    
                    // Initialize with the first way in the set.
                    min_way = 0;
                    min_count = frequency[index][0 * COUNTERW +: COUNTERW];
                    
                    // Loop through all ways to find the one with the minimum frequency.
                    for (k = 1; k < NWAYS; k = k + 1) begin
                        current_count = frequency[index][k * COUNTERW +: COUNTERW];
                        if (current_count < min_count) begin
                            min_count = current_count;
                            min_way = k;
                        end
                        // Tie condition: retain the lower index (min_way remains unchanged).
                    end
                    
                    // Set the counter of the replaced way to 1.
                    frequency[index][min_way * COUNTERW +: COUNTERW] <= 1;
                    
                    // Output the replacement way.
                    way_replace <= min_way;
                end
            end
        end
    end

endmodule