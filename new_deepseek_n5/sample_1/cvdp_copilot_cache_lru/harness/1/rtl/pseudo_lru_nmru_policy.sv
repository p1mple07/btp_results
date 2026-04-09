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
    else begin

        // Update recency on hit
        if (hit) begin
            recency[way_select] = 1;
        end

        // Determine replacement way
        integer lru_count = 0;
        integer nmru_count = 0;
        integer lru_way = -1;
        integer nmru_way = -1;

        // Count zeros and find LRU/NMRU candidates
        for (int i = 0; i < NWAYS; i = i + 1) begin
            if (recency[i] == 0) begin
                lru_count = lru_count + 1;
                lru_way = i;
            end else if (recency[i] == 0) begin
                nmru_count = nmru_count + 1;
                nmru_way = i;
            end
        end

        // If only one zero, use LRU policy
        if (lru_count == 1) begin
            way_replace = lru_way;
        // Else use NMRU policy (smallest index)
        else begin
            way_replace = nmru_way;
        end
    end
end

endmodule