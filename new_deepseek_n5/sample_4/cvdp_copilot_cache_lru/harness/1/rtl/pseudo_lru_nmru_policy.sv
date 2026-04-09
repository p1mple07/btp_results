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

reg [NWAYS-1:0][NINDEXES-1:0] recency;

function integer find_first_zero bit [NWAYS-1:0] recency_row;
    integer i;
    for (i = 0; i < NWAYS; i = i + 1) begin
        if (recency_row[i] == 0) begin
            return i;
        end
    end
    return -1;
endfunction

always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        integer reset_counter;
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    else begin
        for (integer index = 0; index < NINDEXES; index = index + 1) begin
            if (hit) begin
                recency[index][way_select] <= 1;
            end else begin
                integer replacement = find_first_zero recency[index];
                if (replacement != -1) begin
                    way_replace <= replacement;
                    recency[index][replacement] <= 0;
                end
            end
        end
    end
end

endmodule