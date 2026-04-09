module lfu_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32,
    parameter COUNTERW = 2
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    reg [(NWAYS * COUNTERW)-1:0] frequency;

    integer i, n;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        end else begin
            if (access) begin
                if (way_select == {1'b0}) begin
                    // Hit: increment frequency
                    frequency[index][(way_select * COUNTERW) +: COUNTERW] <= frequency[index][(way_select * COUNTERW) +: COUNTERW] + 1;
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] == MAX_FREQUENCY) begin
                        // Decrement counters of other ways with higher frequency
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (frequency[n][(n * COUNTERW) +: COUNTERW] > 2) begin
                                frequency[n][(n * COUNTERW) +: COUNTERW] <= frequency[n][(n * COUNTERW) +: COUNTERW] - 1;
                            end
                        end
                    end
                end
            end else begin
                // Miss: find least frequently used way
                integer min_freq = INFINITY;
                integer best_idx = NWAYS;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (frequency[n][0] < min_freq) begin
                        min_freq = frequency[n][0];
                        best_idx = n;
                    end
                end
                way_replace = best_idx;
            end
        end
    end

endmodule
