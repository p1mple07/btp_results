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
            recency[index] <= {way_select{1'b1}, recency[index] - 1'b1};
        end

        if (hit) begin
            recency[index] <= {1'b1, recency[index]};
        end

        if (recency[index] == {NWAYS{1'b0}}) begin
            way_replace = way_select;
            recency[index] <= {NWAYS{1'b0}};
        end else if (recency[index].count(1'b0) > 1) begin
            // NMRU policy
            int smallest_zero_index = NINDEXES;
            for (int i = 0; i < NINDEXES; i++) begin
                if (recency[i] == {NWAYS{1'b0}}) begin
                    smallest_zero_index = i;
                    break;
                end
            end
            way_replace = way_select[smallest_zero_index];
        end else begin
            // LRU policy
            way_replace = recency[index];
            recency[index] <= {1'b1, recency[index]};
        end
    end
end

endmodule : pseudo_lru_nmru_policy
