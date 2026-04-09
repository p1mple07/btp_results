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

reg [NWAYS*NINDEXES-1:0] recency;

integer reset_counter;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < NWAYS*NINDEXES; i++) recency[i] <= 0;
    end else begin
        if (access && hit) begin
            localvar int idx = index * NWAYS + way_select;
            recency[idx] <= 1;
        end else begin
            localvar int way_replace = -1;
            for (int j = 0; j < NWAYS*NINDEXES; j++) begin
                if (recency[index * NWAYS + j] == 0) begin
                    if (way_replace == -1) begin
                        way_replace = j;
                    end
                    break;
                end
            end
            if (way_replace != -1) begin
                way_replace = way_replace;
            end
        end
    end
end

endmodule
