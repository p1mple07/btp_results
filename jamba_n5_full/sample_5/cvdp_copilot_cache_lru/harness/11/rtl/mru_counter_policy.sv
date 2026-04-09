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

            end
        end
    end

    assign way_replace = 
        mru_slot;

    always_ff @(posedge clock or posedge reset) begin
        if (hit) begin
            recency[index][way_index] <= NWAYS - 1;

            for (j = 0; j < NWAYS; j = j + 1) begin
                if (recency[index][j] > recency[index][way_index]) begin
                    recency[index][j] <= recency[index][j] - 1;
                end
            end

            mru_slot = index[argmax(recency[index])];
        end
    end

endmodule
