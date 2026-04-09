module pseudo_lru_nmru_policy #(
    NWAYS = 4,
    NINDEXES = 32
) (
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

reg [NWAYS-1:0] recency [NINDEXES-1:0];

integer reset_counter;
always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    end else begin
        // Update recency upon hit
        if (hit) begin
            recency[index][way_select] <= 1'b1;
        end

        // Determine way to replace
        integer num_zero_bits;
        num_zero_bits = $countones({recency[index]} == 1'b0);
        if (num_zero_bits == 1) begin
            // LRU case
            way_replace <= way_select;
            for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
                if (reset_counter!= index) begin
                    recency[reset_counter] <= {NWAYS{1'b0}};
                end
            end
        end else if (num_zero_bits > 1) begin
            // NMRU case
            integer min_index;
            min_index = 0;
            for (reset_counter = 1; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
                if ($countones({recency[reset_counter]} == 1'b0) < $countones({recency[min_index]} == 1'b0)) begin
                    min_index = reset_counter;
                end
            end
            way_replace <= way_select;
            recency[min_index] <= {NWAYS{1'b0}};
        end
    end
end

endmodule