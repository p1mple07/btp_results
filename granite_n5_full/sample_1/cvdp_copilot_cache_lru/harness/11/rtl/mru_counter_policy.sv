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

    // Recency Array Update Logic
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NINDEXES; i = i + 1) begin
                for (int n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access &&!hit) begin
                recency[index][((way_select) * $clog2(NWAYS)) +: $clog2(NWAYS)] <= ((way_select) * $clog2(NWAYS)) +: $clog2(NWAYS);
                for (int n = 0; n < NWAYS; n = n + 1) begin
                    if (n!= way_select) begin
                        recency[index][((n) * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][((n) * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                    end
                end
            end
        end
    end

    // MRU Replacement Logic
    assign way_replace = maxval({recency[index], {($clog2(NWAYS)-1){1'b0}}}]);
    function automatic int maxval;
        int max;
        for (max = 0; max < $clog2(NWAYS); max = max + 1) begin
            if (recency[index][max] == $clog2(NWAYS)'(NWAYS-1)) begin
                break;
            end
        end
        maxval = max;
    endfunction

endmodule