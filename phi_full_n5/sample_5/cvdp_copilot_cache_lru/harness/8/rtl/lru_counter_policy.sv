module lru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    // Recency Update Logic
    always_comb begin
        if (access && hit) begin
            recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)] = NWAYS - 1;
            foreach (recency[index][n]) begin
                if (recency[index][n] > NWAYS - 1) begin
                    recency[index][n] = recency[index][n] - 1;
                end
            end
        end
    end

    // LRU Replacement Logic
    assign way_replace = {{NWAYS{1'b0}}, recency[index].max_values - 1};

endmodule : lru_counter_policy
