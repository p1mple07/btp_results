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

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        end else begin
            if (access) begin
                // Select the MRU slot
                mru_slot = 0;
                for (i = 0; i < NINDEXES; i = i + 1) begin
                    if (hit[i]) begin
                        // On cache hit, set the accessed way's counter to NWAYS-1
                        mru_slot = way_select[i];
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n == way_select[i]) begin
                                recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAYS-1);
                            end else begin
                                // Decrement all other counters
                                recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                            end
                        end
                    end
                end
            end
        end
        // Assign way_replace with the MRU slot
        way_replace = mru_slot;
    end

endmodule : mru_counter_policy
