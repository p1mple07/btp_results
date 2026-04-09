module mru_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
)(
    input  clock,
    input  reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0] way_select,
    input  access,
    input  hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

    // Define counter width based on number of ways.
    localparam CW = $clog2(NWAYS);

    // recency array: for each cache index, store a contiguous set of counters,
    // one per way. Each counter is CW bits wide.
    reg [(NWAYS * CW)-1:0] recency [NINDEXES-1:0];

    integer i, n;

    // Sequential block: all updates occur on the rising edge of clock or asynchronous reset.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Initialization: for each index and each way, initialize the counter
            // with a unique value from 0 to NWAYS-1 in ascending order.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    recency[i][(n * CW) +: CW] <= n;
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // -----------------------------------------------------------
                    // Cache Hit: Update recency for the accessed way.
                    // -----------------------------------------------------------
                    // Save the old counter value for the accessed way.
                    reg [CW-1:0] old_val;
                    old_val = recency[index][(way_select * CW) +: CW];
                    
                    // Set the accessed way's counter to maximum (MRU).
                    recency[index][(way_select * CW) +: CW] <= (NWAYS-1);
                    
                    // Decrement all other counters that are greater than the old value.
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != way_select) begin
                            if (recency[index][(n * CW) +: CW] > old_val)
                                recency[index][(n * CW) +: CW] <= recency[index][(n * CW) +: CW] - 1;
                        end
                    end
                    
                    // For a hit, drive the replacement output to the accessed way.
                    way_replace <= way_select;
                end else begin
                    // -----------------------------------------------------------
                    // Cache Miss: Select the MRU way for replacement.
                    // -----------------------------------------------------------
                    // Find the way with the maximum counter value.
                    reg [CW-1:0] temp_mru;
                    integer j;
                    temp_mru = 0;
                    for (j = 0; j < NWAYS; j = j + 1) begin
                        if (recency[index][(j * CW) +: CW] > recency[index][(temp_mru * CW) +: CW])
                            temp_mru = j;
                    end
                    
                    // Update the recency for the replaced way.
                    // (Since it is the MRU, its counter is already (NWAYS-1),
                    // but we perform the same update pattern as for a hit.)
                    reg [CW-1:0] replaced_val;
                    replaced_val = recency[index][(temp_mru * CW) +: CW];
                    recency[index][(temp_mru * CW) +: CW] <= (NWAYS-1);
                    for (n = 0; n < NWAYS; n = n + 1) begin
                        if (n != temp_mru) begin
                            if (recency[index][(n * CW) +: CW] > replaced_val)
                                recency[index][(n * CW) +: CW] <= recency[index][(n * CW) +: CW] - 1;
                        end
                    end
                    
                    // Drive the replacement output to the selected MRU way.
                    way_replace <= temp_mru;
                end
            end else begin
                // No access: Optionally, you can leave way_replace unchanged or set a default.
                // Here, we simply retain the previous value.
            end
        end
    end

endmodule