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
    else begin
        // Update recency on hit
        case (way_select)
            when (8'd1) recency[8'd0] <= 1;
            when (8'd2) recency[8'd1] <= 1;
            when (8'd3) recency[8'd2] <= 1;
            default: recency[8'd3] <= 1;
        endcase

        // Determine replacement way
        integer zeros = 0;
        for (int i = 0; i < NWAYS; i = i + 1) begin
            if (recency[i] == 0) begin
                zeros = i;
                break;
            end
        end

        if (zeros == 0) begin
            way_replace = 0;
        else begin
            for (int i = 0; i < NWAYS; i = i + 1) begin
                if (recency[i] == 0) begin
                    way_replace = i;
                    break;
                end
            end
        end
    end
end

endmodule