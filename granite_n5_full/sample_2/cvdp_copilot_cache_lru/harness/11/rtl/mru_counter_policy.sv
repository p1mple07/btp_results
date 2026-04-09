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
    integer i, n;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)] <= $clog2(NWAYS)'((way_select == mru_slot)? NWAYS - 1 : recency[index][way_select * $clog2(NWAYS) +: $clog2(NWAYS)]);
            end
        end
    end

    generate
        for (n = 0; n < NINDEXES; n = n + 1) begin : g_ways
            assign way_replace = mru_slot;
        end
    endgenerate

endmodule