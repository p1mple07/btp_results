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

    integer i, n;

    // Reset logic
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end
    end

    // Recency update logic
    always @(posedge clock) begin
        if (access &&!hit) begin
            // Set the accessed way to NWAYS-1 and decrement other counters
            for (i = 0; i < NINDEXES; i = i + 1) begin
                if (index == i) begin
                    recency[i][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAYS-1);
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n!= way_select) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                        end
                    end
                end
            end
        end
    end

    // LRU replacement logic
    always @(posedge clock) begin
        if (!access && hit) begin
            // Find the least recently used (LRU) way
            lru_slot_found <= 0;
            for (i = 0; i < NINDEXES; i = i + 1) begin
                lru_slot <= recency[i].rfind($clog2(NWAYS)'(0));
                if (lru_slot_found == 0) begin
                    lru_slot_found <= 1;
                    way_replace <= lru_slot[$clog2(NWAYS)-1:0];
                end
            end
        end
    end

    // Single-cycle latency guarantee
    // Code already provided in the original problem description

endmodule