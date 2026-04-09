module lru_counter_policy #(
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

    wire lru_slot_found;
    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, j, k;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (j = 0; j < NWAYS; j = j + 1) begin
                    recency[i][(j * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(j);
                end
            end
        end else begin
            if (access &&!hit) begin
                recency[index][(way_select * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAYS-1);

                for (k = 0; k < NWAYS; k = k + 1) begin
                    if (k!= way_select) begin
                        recency[index][(k * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(k * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                    end
                end
            end

            // Implementation of the LRU replacement logic goes here

            // Example:
            // if (hit) begin
            //     lru_slot_found <= 1'b1;
            //     lru_slot <= recency[index].rfind($clog2(NWAYS));
            // end else begin
            //     lru_slot_found <= 1'b0;
            //     lru_slot <= '0;
            // end

            // Example of how to implement the LRU replacement logic:
            if (hit) begin
                lru_slot_found <= 1'b1;
                lru_slot <= recency[index].rfind($clog2(NWAYS));
            end else begin
                lru_slot_found <= 1'b0;
                lru_slot <= '0;
            end

            if (access && hit) begin
                recency[index][(lru_slot * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(NWAY-1);

                for (k = 0; k < NWAYS; k = k + 1) begin
                    if (k!= lru_slot) begin
                        recency[index][(k * $clog2(NWAYS)) +: $clog2(NWAYS)] <= recency[index][(k * $clog2(NWAYS)) +: $clog2(NWAYS)] - 1;
                    end
                end
            end

        end
    end

endmodule