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
            // Set recency bit to 1 for the accessed way
            recency[index] <= {way_select{1'b1}, NWAYS{1'b0}};

            // Determine way to replace based on recency
            integer zero_count;
            integer zero_index;
            zero_count = 0;
            zero_index = -1;
            for (integer i = 0; i < NWAYS; i = i + 1) begin
                if (recency[index][i] == 0) begin
                    if (zero_count == 0) begin
                        // LRU policy: Set the lowest index with zero recency
                        zero_index = i;
                        zero_count = 1;
                    end else if (zero_count == 1) begin
                        zero_index = i;
                    end
                end
            end

            if (zero_count == 1) begin
                // LRU policy: Select the way with zero recency
                way_replace <= {zero_index{1'b1}, NWAYS{1'b0}};
            end else if (zero_count > 1) begin
                // NMRU policy: Select any way with zero recency
                way_replace <= way_select; // Any zero recency bit can be selected
            end
        end
    end
end

endmodule : pseudo_lru_nmru_policy
