module pseudo_lru_nmru_policy #(
    parameter int NWAYS = 4,
    parameter int NINDEXES = 32
) (
    input         clock,
    input         reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0]  way_select,
    input         access,
    input         hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // recency array: one per cache set (index), each with NWAYS bits.
    reg [NWAYS-1:0] recency [NINDEXES-1:0];

    integer i;
    integer reset_counter;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize all recency bits to zero.
            for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
                recency[reset_counter] <= {NWAYS{1'b0}};
            end
        end else begin
            // On a cache hit, mark the accessed way as recently used.
            if (hit) begin
                recency[index][way_select] <= 1'b1;
            end

            // Variables for candidate computation.
            integer zero_count;
            integer candidate;
            reg [NWAYS-1:0] zero_mask;
            zero_mask = {NWAYS{1'b1}};  // initialize mask to all ones

            // Build zero_mask: mark positions where recency bit is 0.
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (recency[index][i] == 1'b0)
                    zero_mask[i] = 1'b1;
                else
                    zero_mask[i] = 1'b0;
            end

            // Count the number of zero bits.
            zero_count = 0;
            for (i = 0; i < NWAYS; i = i + 1) begin
                if (zero_mask[i] == 1'b1)
                    zero_count = zero_count + 1;
            end

            if (zero_count == 1) begin
                // LRU mode: exactly one way is not recently used.
                // Find that single zero bit.
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (zero_mask[i] == 1'b1) begin
                        candidate = i;
                        break;
                    end
                end
                // Update recency: mark the selected way as used and reset others.
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (i == candidate)
                        recency[index][i] <= 1'b1;
                    else
                        recency[index][i] <= 1'b0;
                end
            end else if (zero_count > 1) begin
                // NMRU mode: more than one way is not recently used.
                // Select the free slot with the smallest index.
                candidate = 0;
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (recency[index][i] == 1'b0) begin
                        candidate = i;
                        break;
                    end
                end
                // Do not update recency bits in NMRU mode.
            end else begin
                // Fallback: if no zero is found, choose way 0 and update recency.
                candidate = 0;
                for (i = 0; i < NWAYS; i = i + 1) begin
                    if (i == candidate)
                        recency[index][i] <= 1'b1;
                    else
                        recency[index][i] <= 1'b0;
                end
            end

            // Drive the replacement candidate output.
            way_replace <= candidate;
        end
    end

endmodule