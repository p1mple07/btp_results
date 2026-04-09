module pseudo_lru_nmru_policy #(
    NWAYS = 4,
    NINDEXES = 32
) (
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

reg [NWAYS-1:0] recency [NINDEXES-1:0];

integer reset_counter;
always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    end else begin
        if (access) begin
            recency[index] <= {(recency[index] == 0) ? 1 : 0, (NWAYS-1)'(recency[index])};
        end
        
        if (hit) begin
            recency[index] <= 1;
        end

        // Find all zero bits in the recency array
        integer zero_count = 0;
        recency_zero_indices = new[NWAYS] int;
        for (int i = 0; i < NWAYS; i++) begin
            if (recency[index][i] == 0) begin
                zero_count++;
                recency_zero_indices[zero_count] = i;
            end
        end

        // LRU behavior
        if (zero_count == 1) begin
            way_replace = recency_zero_indices[zero_count];
            recency[index][way_replace] = 1;
            for (int i = 0; i < NWAYS; i++) begin
                if (i != way_replace) begin
                    recency[index][i] = 0;
                end
            end
        end

        // NMRU behavior
        else if (zero_count > 1) begin
            // Find the index with the smallest recency value
            int min_index = NWAYS-1;
            for (int i = 0; i < zero_count; i++) begin
                if (recency[index][recency_zero_indices[i]] < recency[index][min_index]) begin
                    min_index = recency_zero_indices[i];
                end
            end
            way_replace = min_index;
        end
    end
end

endmodule : pseudo_lru_nmru_policy
