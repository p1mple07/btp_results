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

    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    // Recency Update Logic
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            // On Cache Hit
            if (access) begin
                // Set the accessed way's counter to NWAYS-1
                recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= NWAYS-1;
                
                // Decrement counters greater than the accessed way's counter
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)]) begin
                        recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                    end
                end
            end

            // Replacement Logic
            // Find the way with the minimum counter value
            lru_slot = $clog2(NWAYS)'(0);
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] < recency[lru_slot][(lru_slot * $clog2(NWAYS)) +: $clog2(NWAYS)]) begin
                        lru_slot = i;
                    end
                end
            end

            // Set the output to the way with the minimum counter value
            way_replace = lru_slot;
        end
    end

endmodule : lru_counter_policy
