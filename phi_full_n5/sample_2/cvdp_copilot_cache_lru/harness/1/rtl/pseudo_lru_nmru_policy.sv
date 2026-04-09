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
            if (hit) begin
                recency[index] <= 1'b1;
            end else begin
                recency[index] <= {NWAYS{1'b0}};
            end

            if (recency[index].count() == 0) begin
                way_replace <= way_select;
                recency[index] <= {NWAYS{1'b1}};
                for (int j = 0; j < NWAYS; j = j + 1) begin
                    recency[index][j] <= 1'b0;
                end
            end else if (recency[index].count() > 1) begin
                // Implement NMRU policy: Select the way with the smallest index
                int smallest_index = NINDEXES - 1;
                for (int j = 0; j < NWAYS; j = j + 1) begin
                    if (recency[index][j] == 1'b1 && smallest_index > j) begin
                        smallest_index = j;
                    end
                end
                way_replace <= way_select[smallest_index];
                recency[index] <= {recency[index][:smallest_index], recency[index][smallest_index+1:NWAYS-1], 1'b1};
            end
        end
    end
end

endmodule : pseudo_lru_nmru_policy
