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

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            // Recency Update Logic
            if (access &&!hit) begin
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    recency[i][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAYS-1);
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n!= way_select && recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] > recency[i][(way_select * $clog2(NWAYS)) +: $clog2(NWAY)]) begin
                            recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAY)] <= recency[i][(way_select * $clog2(NWAYS)) +: $clog2(NWAY)] - 1;
                        end
                    end
                end
            end

            // Replacement Logic
            lru_slot_found <= (way_select == lru_slot);
            if (hit && lru_slot_found) begin
                way_replace <= lru_slot;
            end
        end
    end

endmodule