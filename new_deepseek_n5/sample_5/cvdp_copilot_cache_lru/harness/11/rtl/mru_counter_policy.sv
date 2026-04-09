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
                // Hit case
                integer current_val;
                current_val = recency[index][way_select];
                recency[index][way_select] <= $clog2(NWAYS)-1;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (n != way_select) begin
                        if (recency[index][n] > current_val) begin
                            recency[index][n] <= recency[index][n] - 1;
                        end
                    end
                end
            else begin
                // Miss case
                integer max_val = -1;
                integer mru_ways = -1;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (recency[index][n] > max_val) begin
                        max_val = recency[index][n];
                        mru_ways = n;
                    end
                end
                recency[index][mru_ways] <= $clog2(NWAYS)-1;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (n != mru_ways) begin
                        if (recency[index][n] > max_val) begin
                            recency[index][n] <= recency[index][n] - 1;
                        end
                    end
                end
            end
        end
    end

    assign way_replace = mru_ways;
endmodule