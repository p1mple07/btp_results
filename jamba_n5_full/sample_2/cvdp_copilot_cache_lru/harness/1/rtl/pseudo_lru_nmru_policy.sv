module pseudo_lru_nmru_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
) (
    input clock,
    input reset,
    input [NINDEXES-1:0] index,
    input [NWAYS-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

reg [NWAYS-1:0] recency [NINDEXES-1:0];

// ...

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < NWAYS; i++) recency[i] <= 0;
    end
    else begin
        // update recency on access
        if (access) begin
            // find the zero bit in recency
            int best_idx = -1;
            for (int i = 0; i < NWAYS; i++) begin
                if (recency[i] == 0) begin
                    if (best_idx == -1) best_idx = i;
                end
            end
            if (best_idx != -1) recency[best_idx] = 1;
        end
    end
end

assign way_replace = ...;
