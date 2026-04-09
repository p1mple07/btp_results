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
                if (hit) begin
                    // Update the accessed way's counter to max value and decrement other counters
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n!= way_select) begin
                            recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                        end
                    end

                    // Set the accessed way's counter to max value
                    recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAYS-1);
                end
            end
        end
    end

    assign way_replace = recency[index].rbegin();

endmodule