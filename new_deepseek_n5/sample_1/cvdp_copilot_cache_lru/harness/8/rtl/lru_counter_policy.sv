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

    integer i, n;

    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * $clog2(NWAYS)) +: $clog2(NWAYS)] <= $clog2(NWAYS)'(n);
                end
            end
        else begin
            // Hit handling
            local integer current_way;
            local integer current_value;
            current_value = recency[index][way_select];
            recency[index][way_select] <= (NWAYS - 1);
            
            for (current_way = 0; current_way < NWAYS; current_way = current_way + 1) begin
                if (recency[index][current_way] > current_value) begin
                    recency[index][current_way] <= recency[index][current_way] - 1;
                end
            end

            // Miss handling
            integer min_value = $clog2(NWAYS);
            integer min_way = 0;
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (recency[index][i] < min_value) begin
                    min_value = recency[index][i];
                    min_way = i;
                end
            end

            recency[index][min_way] <= (NWAYS - 1);
            
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (recency[index][i] > min_value) begin
                    recency[index][i] <= recency[index][i] - 1;
                end
            end

            way_replace <= min_way;
        end
    end
endmodule