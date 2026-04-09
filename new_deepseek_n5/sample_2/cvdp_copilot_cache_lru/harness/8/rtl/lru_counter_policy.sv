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
    output [$clog2(NWAYS)-1:0] way_replace
);

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    wire lru_slot_found;
    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n, w;

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        else begin

            // Hit Case
            if (access) begin
                // Store current value of accessed way
                integer prev_value = recency[index][way_select];
                
                // Update accessed way to max value
                recency[index][way_select] <= $clog2(NWAYS)'(NWAYS-1);

                // Decrement counters for ways with higher values
                for (w = 0; w < NWAYS; w = w + 1) begin
                    if (w != way_select) begin
                        if (recency[index][w] > prev_value) begin
                            recency[index][w] <= recency[index][w] - 1;
                        end
                    end
                end
            end

            // Miss Case
            if (!access) begin
                // Find the way with minimum counter value
                integer min_val = $clog2(NWAYS)'(NWAYS-1);
                integer lru_ways = 0;
                
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    for (w = 0; w < NWAYS; w = w + 1) begin
                        if (recency[i][w] < min_val) begin
                            min_val = recency[i][w];
                            lru_ways = w;
                        end
                    end
                end

                // Update replaced way to max value
                recency[index][lru_ways] <= $clog2(NWAYS)'(NWAYS-1);

                // Decrement counters for ways with higher values
                for (w = 0; w < NWAYS; w = w + 1) begin
                    if (w != lru_ways) begin
                        if (recency[index][w] > min_val) begin
                            recency[index][w] <= recency[index][w] - 1;
                        end
                    end
                end
            end
        end
    end
endmodule