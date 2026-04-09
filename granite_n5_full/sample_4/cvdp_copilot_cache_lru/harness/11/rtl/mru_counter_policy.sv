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
                // Update the accessed way to max value and decrement other counters
                recency[index][way_select +: $clog2(NWAYS)] <= '1;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (n!= way_select && n > recency[index][way_select +: $clog2(NWAYS)]) begin
                        recency[index][n +: $clog2(NWAYS)] <= recency[index][n +: $clog2(NWAY)] - 1;
                    end
                }
            end
        end
    end

    assign way_replace = 
        (access && hit)? '1 : // Replace the accessed way if it is hit
        (access &&!hit)? '0 : // Leave the accessed way unchanged if it is not hit
        (way_select == mru_slot)? '1 : // Replace the MRU way if it matches the selected way
        '0; // Keep the original way if it does not match the selected way

endmodule