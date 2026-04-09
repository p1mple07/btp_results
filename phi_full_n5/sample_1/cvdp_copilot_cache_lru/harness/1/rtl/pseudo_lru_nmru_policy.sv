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
    output [$clog2(NWAYS)-1:0] way_replace
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
                recency[index] <= {NWAYS{1'b1}};
                way_replace <= way_select;
            end else begin
                recency[index] <= {NWAYS{1'b0}};
            end

            // Find the index with the least non-zero recency
            integer free_slot = NWAYS;
            for (int i = 0; i < NWAYS; i++) begin
                if (recency[index][i] == 1'b0) begin
                    free_slot = i;
                    break;
                end
            end

            if (free_slot != NWAYS) begin
                way_replace <= way_select & recency[index][free_slot];
            end else begin
                // If all recency bits are 0, select any way
                way_replace <= way_select;
            end
        end
    end
end

endmodule : pseudo_lru_nmru_policy
