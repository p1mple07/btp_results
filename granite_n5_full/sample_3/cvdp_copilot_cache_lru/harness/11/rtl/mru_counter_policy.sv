module mru_counter_policy #(
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

    // Declare recency array
    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // Reset logic
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NINDEXES; i++) begin
                for (int j = 0; j < NWAYS; j++) begin
                    recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(j);
                end
            end
        end
    end

    // Update logic on cache hit
    always @(posedge clock) begin
        if (access && hit) begin
            int mru_slot = 0;
            int max_val = 0;
            for (int i = 0; i < NINDEXES; i++) begin
                for (int j = 0; j < NWAYS; j++) begin
                    if (recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_val) begin
                        mru_slot = i;
                        max_val = recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)];
                    end
                end
            end
            for (int i = 0; i < NINDEXES; i++) begin
                for (int j = 0; j < NWAYS; j++) begin
                    if (i == mru_slot && j!= way_select) begin
                        recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(max_val - 1);
                    end
                end
            end
        end
    end

    // Way replacement logic
    always @(posedge clock) begin
        if (access &&!hit) begin
            int mru_slot = 0;
            int max_val = 0;
            for (int i = 0; i < NINDEXES; i++) begin
                for (int j = 0; j < NWAYS; j++) begin
                    if (recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] > max_val) begin
                        mru_slot = i;
                        max_val = recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)];
                    end
                end
            end
            way_replace <= mru_slot;
        end
    end

endmodule