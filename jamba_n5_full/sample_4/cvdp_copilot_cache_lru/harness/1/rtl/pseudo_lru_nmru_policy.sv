module pseudo_lru_nmru_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
) (
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

reg [NWAYS-1:0] recency [NINDEXES-1:0];

// Reset initialization
always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < NINDEXES; i++) recency[i] <= 0;
    end
    else begin
        // After reset, we need to reinitialize recency? But it's already zero.
        // But we might need to recompute after reset.
        // Since reset sets all to zero, we can skip.
    end
end

always_ff @(posedge clock) begin
    if (access) begin
        // On access, set the recency for that way to 1.
        recency[way_select] <= 1;
    end
end

always_ff @(posedge clock) begin
    // Find the way to replace.
    integer zero_count = 0;
    int chosen_way = -1;
    for (int i = 0; i < NWAYS; i++) begin
        if (recency[i] == 0) begin
            zero_count++;
            if (chosen_way == -1) chosen_way = i;
        end
    end
    if (zero_count > 0) begin
        // There is at least one zero.
        if (zero_count == 1) begin
            // Pick the only zero way.
            way_replace = chosen_way;
        end else begin
            // NMRU: choose the smallest index among zeros.
            for (int j = 0; j < NWAYS; j++) begin
                if (recency[j] == 0) begin
                    if (j < chosen_way) chosen_way = j;
                end
            end
            way_replace = chosen_way;
        end
    end
    else begin
        // No hit? But we might need to handle no hit. But the spec says on hit, set recency. So this case should not occur.
        way_replace = 0;
    end
end

endmodule
