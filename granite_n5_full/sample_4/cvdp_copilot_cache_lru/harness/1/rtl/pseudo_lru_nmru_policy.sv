module pseudo_lru_nmru_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
) (
    input wire clock,
    input wire reset,
    input wire [$clog2(NINDEXES)-1:0] index,
    input wire [$clog2(NWAYS)-1:0] way_select,
    input wire access,
    input wire hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

reg [NWAYS-1:0][NINDEXES-1:0] recency;

integer reset_counter;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    end else begin
        if (access && hit) begin
            recency[index][way_select] <= 1'b1;
        end

        // Handle NMRU policy when multiple bits are zero
        integer i;
        for (i = 0; i < NINDEXES; i = i + 1) begin
            if (!access ||!hit) begin
                if (recency[i][way_select] == 1'b0) begin
                    way_replace <= i;
                    break;
                end
            end
        end
    end
end

endmodule