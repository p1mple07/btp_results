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
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Define counter width for each cache way
    localparam COUNTER_WIDTH = $clog2(NWAYS);

    // Recency array: each cache index holds NWAYS counters, each of COUNTER_WIDTH bits.
    reg [(NWAYS * COUNTER_WIDTH)-1:0] recency [NINDEXES-1:0];

    // Wires for combinational LRU replacement logic
    wire lru_slot_found;
    wire [$clog2(NWAYS)-1:0] lru_slot;

    integer i, n;

    // Sequential logic: update recency array on clock edge
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialization: Set each counter to a unique value (0 to NWAYS-1)
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][n * COUNTER_WIDTH +: COUNTER_WIDTH] <= n;
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // Recency Update Logic for Cache Hit
                    // Get previous counter value for the accessed way
                    reg [COUNTER_WIDTH-1:0] accessed_prev;
                    accessed_prev = recency[index][way_select * COUNTER_WIDTH +: COUNTER_WIDTH];
                    // Set accessed way's counter to maximum (NWAYS-1), marking it as most recently used
                    recency[index][way_select * COUNTER_WIDTH +: COUNTER_WIDTH] <= (NWAYS - 1);
                    // Decrement counters for all other ways with value greater than accessed_prev
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != way_select) begin
                            if (recency[index][n * COUNTER_WIDTH +: COUNTER_WIDTH] > accessed_prev) begin
                                recency[index][n * COUNTER_WIDTH +: COUNTER_WIDTH] <= recency[index][n * COUNTER_WIDTH +: COUNTER_WIDTH] - 1;
                            end
                        end
                    end
                end else begin
                    // Recency Update Logic for Cache Miss (Replacement)
                    // Determine the least recently used (LRU) way for replacement
                    integer j;
                    reg [COUNTER_WIDTH-1:0] min_val;
                    reg [COUNTER_WIDTH-1:0] replaced_prev;
                    integer lru_way;
                    min_val = recency[index][0 * COUNTER_WIDTH +: COUNTER_WIDTH];
                    replaced_prev = min_val;
                    lru_way = 0;
                    for (j = 1; j < NWAYS; j = j + 1) begin
                        if (recency[index][j * COUNTER_WIDTH +: COUNTER_WIDTH] < min_val) begin
                            min_val = recency[index][j * COUNTER_WIDTH +: COUNTER_WIDTH];
                            replaced_prev = min_val;
                            lru_way = j;
                        end
                    end
                    // Set the counter of the replaced (LRU) way to maximum (NWAYS-1)
                    recency[index][lru_way * COUNTER_WIDTH +: COUNTER_WIDTH] <= (NWAYS - 1);
                    // Decrement counters for all other ways with value greater than replaced_prev
                    for (j = 0; j < NWAYS; j = j + 1) begin
                        if (j != lru_way) begin
                            if (recency[index][j * COUNTER_WIDTH +: COUNTER_WIDTH] > replaced_prev) begin
                                recency[index][j * COUNTER_WIDTH +: COUNTER_WIDTH] <= recency[index][j * COUNTER_WIDTH +: COUNTER_WIDTH] - 1;
                            end
                        end
                    end
                end
            end
            // If access is deasserted, no update occurs.
        end
    end

    // Combinational Logic: Determine LRU way for replacement
    always_comb begin
        integer k;
        reg [COUNTER_WIDTH-1:0] cur;
        reg [COUNTER_WIDTH-1:0] min_val;
        lru_slot = 0;
        min_val = recency[index][0 * COUNTER_WIDTH +: COUNTER_WIDTH];
        for (k = 1; k < NWAYS; k = k + 1) begin
            cur = recency[index][k * COUNTER_WIDTH +: COUNTER_WIDTH];
            if (cur < min_val) begin
                min_val = cur;
                lru_slot = k;
            end
        end
        lru_slot_found = 1'b1; // Always valid
    end

    // Drive the replacement output with the selected LRU way
    assign way_replace = lru_slot;

endmodule