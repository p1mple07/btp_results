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
reg reset_counter;

integer reset_counter;
always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    else begin

        if (hit) begin
            recency[index] <= 1;
        else begin
            // Find all ways with zero recency
            reg [NWAYS-1:0] zero_ways;
            for (int i = 0; i < NWAYS; i = i + 1) begin
                if (recency[i] == 0) begin
                    zero_ways <= i;
                end
            end

            // If only one zero way, use it
            if (zero_ways[0] != -1) begin
                way_replace <= zero_ways[0];
                recency[way_replace] <= 1;
                for (int i = 0; i < NWAYS; i = i + 1) begin
                    if (i != way_replace) begin
                        recency[i] <= 0;
                    end
                end
            // If multiple zeros, use smallest index
            else begin
                way_replace <= zero_ways;
                recency[way_replace] <= 1;
                for (int i = 0; i < NWAYS; i = i + 1) begin
                    if (i != way_replace) begin
                        recency[i] <= 0;
                    end
                end
            end
        end
    end
end

endmodule