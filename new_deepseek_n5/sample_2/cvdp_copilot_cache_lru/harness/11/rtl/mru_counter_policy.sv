module mru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    reg [(NWAYS * $clog2(NWAYS))-1:0] recency [NINDEXES-1:0];

    wire [$clog2(NWAYS)-1:0] mru_slot;

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        else begin
            if (access) begin
                // Hit case: Update recency array
                way = way_select;
                offset = way * $clog2(NWAYS);
                recency[index][way] <= (NWAYS - 1);
                for (n = way - 1; n >= 0; n = n - 1) begin
                    if (recency[index][n + offset] == (NWAYS - 1)) break;
                    recency[index][n + offset] <= recency[index][n + offset] - 1;
                end
            else begin
                // Miss case: Find MRU slot for replacement
                max_counter = 0;
                max_way = 0;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[index][n + offset] > recency[index][max_way + offset]) begin
                        max_way = n;
                        max_counter = recency[index][max_way + offset];
                    end
                end
                way_replace = max_way;
                offset = max_way * $clog2(NWAYS);
                recency[index][offset] <= (NWAYS - 1);
                for (n = max_way - 1; n >= 0; n = n - 1) begin
                    if (recency[index][n + offset] == (NWAYS - 1)) break;
                    recency[index][n + offset] <= recency[index][n + offset] - 1;
                end
            end
        end
    end

endmodule