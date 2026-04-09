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

    reg [(NWAYS * COUNTERW)-1:0] frequency; // size: NWAYS * COUNTERW

    integer i, n;

    // Reset logic
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NWAYS * COUNTERW; i = i + 1) begin
                frequency[i] <= 0;
            end
        end
    end

    // Handle access
    always_comb begin
        if (access) begin
            if (hit) begin
                // Increment frequency if not at max
                if (frequency[index * COUNTERW + way_select] < MAX_FREQUENCY) begin
                    frequency[index * COUNTERW + way_select] <= frequency[index * COUNTERW + way_select] + 1;
                end
            end else {
                // Miss: find least frequent way
                int min_freq = INF;
                int best_way = -1;
                for (n = 0; n < NWAYS; n = n + 1) begin
                    if (frequency[n * COUNTERW + way_select] < min_freq) begin
                        min_freq = frequency[n * COUNTERW + way_select];
                        best_way = n;
                    end
                end

                way_replace = best_way;
                frequency[best_way * COUNTERW + way_select] <= 1;
            end
        end
    end

endmodule
