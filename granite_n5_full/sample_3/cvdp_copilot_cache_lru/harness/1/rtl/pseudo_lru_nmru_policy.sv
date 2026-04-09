module pseudo_lru_nmru_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
) (
    input clock,
    input reset,
    input [NINDEXES-1:0] index,
    input [NWAYS-1:0] way_select,
    input access,
    input hit,
    output [NWAYS-1:0] way_replace
);

reg [NWAYS-1:0] recency [NINDEXES-1:0];

integer reset_counter;
always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
            recency[reset_counter] <= {NWAYS{1'b0}};
        end
    end else begin

    end
end

assign way_replace = (|recency & ~|recency)? $min(way_select, recency) : way_select;

always_comb begin
    if (access &&!hit) begin
        for (int i = 0; i < NINDEXES; i++) begin
            if (index == i) begin
                recency[i][way_select] = 1'b1;
            end
        end
    end
end

endmodule