module pseudo_lru_tree_policy #(
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

    localparam int unsigned NBITS_TREE = NWAYS - 1;

    // Recency array to keep track of next way to be replaced
    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];

    // Sequential logic for reset and recency updates
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (int i = 0 to NINDEXES-1:0):
                recency[i] = 0 to NINDEXES-1:0